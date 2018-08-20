UTILS := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))/.makefile-utils.sh

OK_COLOR     = \033[0;32m
NO_COLOR     = \033[m

DOCKER_USER = topheman
DOCKER_IMAGE_PREFIX = $(DOCKER_USER)/docker-experiments
DOCKER_IMAGE_NAME_FRONT_DEV = $(DOCKER_IMAGE_PREFIX)_front_development
DOCKER_IMAGE_NAME_API_DEV = $(DOCKER_IMAGE_PREFIX)_api_development
DOCKER_IMAGE_NAME_API_PROD = $(DOCKER_IMAGE_PREFIX)_api_production
DOCKER_IMAGE_NAME_NGINX = $(DOCKER_IMAGE_PREFIX)_nginx

TAG_LATEST = latest
TAG ?= 1.0.0

# development docker-compose
COMPOSE              = docker-compose
COMPOSE_RUN          = $(COMPOSE) run --rm
COMPOSE_RUNCI        = $(COMPOSE_RUN) -e CI=true
COMPOSE_RUN_FRONT    = $(COMPOSE_RUN) front
COMPOSE_RUNCI_FRONT  = $(COMPOSE_RUNCI) front
COMPOSE_RUN_API      = $(COMPOSE_RUN) api

# production docker-compose
COMPOSEPROD          = docker-compose -f ./docker-compose.yml -f ./docker-compose.prod.yml

# kubernetes
KUBECTL_CONFIG       = -f ./deployments/api.yml -f ./deployments/front.yml

default: help

.PHONY: build-front-assets dev-logs-api dev-logs-front dev-logs dev-ps dev-start-d dev-start dev-stop docker-build-prod docker-images-clean docker-images-id docker-images-name docker-images kube-ps kube-start-no-rebuild kube-start kube-stop prod-logs-api prod-logs-front prod-logs prod-ps prod-start-d-no-rebuild prod-start-d prod-start-no-rebuild prod-start prod-stop test-api test-front test

# rename ?
build-front-assets: ## Build frontend assets into ./front/build folder
	$(COMPOSE_RUN_FRONT) npm run build

test-front: ## Test react frontend
	$(COMPOSE_RUNCI_FRONT) npm run -s test

test-api: ## Test golang backend
	$(COMPOSE_RUN_API) go test -run ''

test: test-front test-api ## 🌡  Test both frontend and backend

docker-images: ## List project's docker images
	@docker images --filter=reference='$(DOCKER_IMAGE_PREFIX)*'

docker-images-name: ## List project's docker images formatted as <name>:<tag>
	@docker images --format "{{.Repository}}:{{.Tag}}" --filter=reference='$(DOCKER_IMAGE_PREFIX)*'

docker-images-id: ## List project's docker images formatted as <id>
	@docker images --quiet --filter=reference='$(DOCKER_IMAGE_PREFIX)*'

docker-images-clean: ## Clean dangling images (tagged as <none>)
	docker rmi $(shell docker images -q --filter="dangling=true")

docker-build-prod: ## Build production images
	$(MAKE) build-front-assets
	docker build ./api -t $(DOCKER_IMAGE_NAME_API_PROD):$(TAG)
	docker build . -f Dockerfile.prod -t $(DOCKER_IMAGE_NAME_NGINX):$(TAG)

dev-start: ## 🐳  Start development stack
	$(COMPOSE) up
dev-start-d: ## Start development stack (in daemon mode)
	$(COMPOSE) up -d
dev-stop: ## Stop development stack
	$(COMPOSE) down
dev-ps: ## List development stack active containers
	$(COMPOSE) ps
dev-logs: ## 🐳  Follow ALL logs (dev)
	$(COMPOSE) logs -f
dev-logs-front: ## Follow front logs (dev)
	$(COMPOSE) logs -f front
dev-logs-api: ## Follow api logs (dev)
	$(COMPOSE) logs -f api

prod-start: ## 🐳  Start production stack (bundles frontend before)
	$(MAKE) build-front-assets
	$(COMPOSEPROD) up --build
prod-start-d: ## Start production stack (in daemon mode)
	$(MAKE)build-front-assets 
	$(COMPOSEPROD) up --build -d
prod-start-no-rebuild: ## 🐳  Start production stack without recreating docker images
	$(COMPOSEPROD) up
prod-start-d-no-rebuild: ## Start production stack (in daemon mode)  without recreating docker images
	$(COMPOSEPROD) up -d
prod-stop: ## Stop production stack
	$(COMPOSEPROD) down
prod-ps: ## List production stack active containers
	$(COMPOSEPROD) ps
prod-logs: ## 🐳  Follow ALL logs (prod)
	$(COMPOSEPROD) logs -f
prod-logs-front: ## Follow front logs (prod)
	$(COMPOSEPROD) logs -f front
prod-logs-api: ## Follow api logs (prod)
	$(COMPOSEPROD) logs -f api

kube-start-no-rebuild: ## Create kubernetes deployment without recreating docker images
	kubectl create $(KUBECTL_CONFIG)
kube-start: ## ☸️  Create kubernetes deployment with fresh docker images
	$(MAKE) docker-build-prod
	@echo ""
	$(MAKE) kube-start-no-rebuild
	@echo "\nYou may use $(OK_COLOR)make kube-start-no-rebuild$(NO_COLOR) next time to avoid rebuilding images each time\n"
kube-stop: ## Delete kubernetes deployment with fresh docker images
	kubectl delete $(KUBECTL_CONFIG)
kube-ps: ## List kubernetes pods and services
	kubectl get pods,services

help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

list-phony:
	# List all the tasks to add the to .PHONY (choose between inlined and linefeed)
	# bash variables are expanded with $$
	# make|sed 's/\|/ /'|awk '{printf "%s+ ", $1}'
	# make|sed 's/\|/ /'|awk '{print $1}'
	@$(MAKE) help|sed 's/\|/ /'|awk '{printf "%s ", $$1}'
	@echo "\n"
	@$(MAKE) help|sed 's/\|/ /'|awk '{print $$1}'

# deprecated - example of how to call a function from an other .sh file
image-exists:
	@. $(UTILS); image_exists $(DOCKER_IMAGE_NAME_NGINX):$(TAG)