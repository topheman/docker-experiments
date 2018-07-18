# my-docker-fullstack-project

Intro comming up

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
  * The `services.api.command` entry in [docker-compose.override.yml](docker-compose.override.yml) will override the default `RUN` command and start a dev server (instead of running the binary compiled a container build time)

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

Thanks to docker multi-stage builds, the golang application is built in a docker golang:alpine image (which contains all the tooling for golang such as compiler/libs ...) and produces a small image with only a binary in an alpine image.

The targets for multi-stage build are specified in the docker*.yml config files.

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
* `docker-compose -f ./docker-compose.yml run --rm api <cmd>`: launc an api container in *production* mode and run `<cmd>`
* `docker-compose down`: stop and remove containers, networks, volumes, and images created by `docker-compose up`

Don't want to use `docker-compose` (everything bellow is already specified in the `docker*.yml` files - only dropping to remember the syntax for the futur) ?

* `docker build ./api -t my-docker-fullstack-project_api_production`: build the `api` and tag it as `my-docker-fullstack-project_api_production` based on [api/Dockerfile](api/Dockerfile)
* `docker run -d -p 5000:5000 my-docker-fullstack-project_api_production`: runs the `my-docker-fullstack-project_api_production` image previously created in daemon mode and exposes the ports

*This is still a work in progress*