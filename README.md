# my-docker-fullstack-project

This is a simple use case to discover `docker`, `docker-compose` and the creation of `Dockerfile` in both development and production:

* A [front](front) made with create-react-app, running in a nodejs container for development (only the built artefacts will be used in production, not this container)
* A very simple [api](api) made in go (the challenge is also not to have everything in JavaScript), containerized in docker with a development and a production image

## Prerequisites

You need to have installed:

* docker / docker-compose
* npm / node (optional)

## Dev mode

### Install / launch

```shell
docker-compose up -d
```

This will create (if not already done) and launch a whole development stack, based on [docker-compose.yml](docker-compose.yml), [docker-compose.override.yml](docker-compose.override.yml), [api/Dockerfile](api/Dockerfile) and [front/Dockerfile](front/Dockerfile) - following images:

* `my-docker-fullstack-project_front_development`: for react development (based on nodejs image)
* `my-docker-fullstack-project_api_development`: for golang in development mode (using [fresh](https://github.com/pilu/fresh) to build and restart the go webserver when you change the sources)
  * The `services.api.command` entry in [docker-compose.override.yml](docker-compose.override.yml) will override the default `RUN` command and start a dev server (instead of running the binary compiled in the container at build time)

Go to http://localhost:3000/ to access the frontend, you're good to go, the api is accessible at http://localhost:5000/.

## Production mode

```shell
docker-compose -f ./docker-compose.yml up
```

This will create (if not already done) and launch a whole production stack only based on [`docker-compose.yml`](docker-compose.yml) and [api/Dockerfile](api/Dockerfile) - following images:

* No nodejs image (it should not be shipped to production, the development image will be used to launch a container that will create the build artefacts with create-react-app).
* `my-docker-fullstack-project_api_production`: for the golang server (with the app compiled) - containing only the binary of the golang app (that way the image)
* An nginx image *TODO*

## Notes

### Docker Multi-stage builds

Thanks to [docker multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/), the golang application is built in a docker golang:alpine image (which contains all the tooling for golang such as compiler/libs ...) and produces a small image with only a binary in an alpine image (small Linux distrib).

The targets for multi-stage build are specified in the `docker*.yml` config files.

The [api/Dockerfile](api/Dockerfile) will create such a production image by default.

You can tell the difference of weight:

```
docker images
REPOSITORY                                      TAG                 IMAGE ID            CREATED             SIZE
my-docker-fullstack-project_api_production      latest              6021ac7d9d2f        43 minutes ago      11.5MB
my-docker-fullstack-project_api_development     latest              755a7ed2bf72        44 minutes ago      426MB
my-docker-fullstack-project_front_development   latest              2a71910b5e8c        About an hour ago   225MB
```

### Commands

* `docker-compose run --rm front npm run test`: launch a front container in *development* mode and run tests
* `docker-compose -f ./docker-compose.yml run --rm api <cmd>`: launch an api container in *production* mode and run `<cmd>`
* `docker-compose down`: stop and remove containers, networks, volumes, and images created by `docker-compose up`

Don't want to use `docker-compose` (everything bellow is already specified in the `docker*.yml` files - only dropping to remember the syntax for the futur) ?

* `docker build ./api -t my-docker-fullstack-project_api_production`: build the `api` and tag it as `my-docker-fullstack-project_api_production` based on [api/Dockerfile](api/Dockerfile)
* `docker run -d -p 5000:5000 my-docker-fullstack-project_api_production`: runs the `my-docker-fullstack-project_api_production` image previously created in daemon mode and exposes the ports
* `docker build ./front -t my-docker-fullstack-project_front_development`: build the `front` and tag it as `my-docker-fullstack-project_front_development` based on [front/Dockerfile](front/Dockerfile)
* `docker run --rm -p 3000:3000 -v $(pwd)/front:/usr/front -v front-deps:/usr/front/node_modules my-docker-fullstack-project_front_development`:
  * runs the `my-docker-fullstack-project_front_development` image previously created in attach mode
  * exposes the port 3000
  * creates (if not exists) and bind the volumes
  * the container will be removed once you kill the process (`--rm`)

## What's next ?

The next thing that will be comming are:

* using [nginx](https://www.nginx.com/) as a reverse-proxy to:
  * serve the golang api which is in its own container on `/api`
  * make a build of the front and serve it at the root
* use [kubernetes](https://kubernetes.io/) to automate deployment
  * start by playing in local with [minikube](https://github.com/kubernetes/minikube)
* add linting / formatting support (eslint/prettier) with advanced config for the JavaScript part
  * the challenge being that any npm dependency is installed on a volume which is mounted inside a container. How to elegantly have lint/formatting task also running on the host without duplicating to much, without relying on global modules (this would be cheating 😉)

**Reminder**: *This project is just starting, it is still in progress*.