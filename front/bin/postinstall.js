const chalk = require("chalk");
const fs = require("fs");

/**
 * Based on https://github.com/sindresorhus/is-docker
 */

function hasDockerEnv() {
	try {
		fs.statSync('/.dockerenv'); // only rely on .dockerenv as fallback
		return true;
	} catch (err) {
		return false;
	}
}

function hasDockerCGroup() {
	try {
		return fs.readFileSync('/proc/self/cgroup', 'utf8').indexOf('docker') !== -1;
	} catch (err) {
		return false;
	}
}

function isDocker() {
	return hasDockerCGroup() || hasDockerEnv();
}

if (!isDocker()) {
  console.log(chalk`
If you installed a new package from the host with {bold yarn add <pkg>}, please update the node_modules inside the docker container.

Run {bold docker-compose run --rm front yarn}
  `)
}