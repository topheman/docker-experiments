#!/usr/bin/env bash
USERNAME="topheman"
DOCKER_IMAGE_PREFIX="$USERNAME/my-docker-fullstack-project_"
DOCKER_IMAGE_NAME_API_PRODUCTION=$DOCKER_IMAGE_PREFIX"api_production"
DOCKER_IMAGE_NAME_FRONT_DEVELOPMENT=$DOCKER_IMAGE_PREFIX"front_development"

isImageBuilt() {
	local output=$(docker images $1 | grep $USERNAME)
	if [[ -z "$output" ]]; then
		echo "[Check] $1: missing 😕"
		return 1
	else
		echo "[Check] $1: exists 👍"
		return 0
	fi
}

checkAllImages() {
	local exitCode=0
	isImageBuilt $DOCKER_IMAGE_NAME_API_PRODUCTION
	exitCode=`expr $exitCode + $?`
	isImageBuilt $DOCKER_IMAGE_NAME_FRONT_DEVELOPMENT
	exitCode=`expr $exitCode + $?`
	return $exitCode
}

build() {
	echo "[Build] Building JavaScript bundle inside front container"
	docker-compose run --rm front npm run build
	if [[ $? -gt 0 ]]; then
		echo "[Fail] Frontend bundling failed"
		return 1
	fi
	return 0
}

help() {
	echo -e "
⚠️   Still in progress ...

\033[1mDescription\033[0m
	This script ensures that the docker images necessary for the production are available,
	then it will build the frontend bundle and inject it in the nginx production image
	and configure that image to reverse proxy /api to serve the backend production container.

\033[1mOptions\033[0m
	--help
		Displays help (default)
	--build
		Will build the production image / bundle frontend
"
}

if [[ $@ = *"--build"* ]]; then
	echo "[Check] Verifying all images"
	checkAllImages
	if [[ $? -gt 0 ]]; then
		echo "[Fail] Some image is missing - aborting 🚫"
		exit 1
	fi
	build
	if [[ $? -gt 0 ]]; then
		echo "[Fail] Build fail - aborting 🚫"
		exit 2
	fi
else
	help
	exit
fi