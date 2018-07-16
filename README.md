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

This will create (if not already done) and launch a whole development stack, based on [`docker-compose.yml`](docker-compose.yml) and [`docker-compose.override.yml`](docker-compose.override.yml):

* A container for nodejs for react development
* A container for golang in development mode (using [fresh](https://github.com/pilu/fresh) to build and restart the go webserver when you change the sources)

Go to http://localhost:3000/ to access the frontend, you're good to go, the api is accessible at http://localhost:5000/.

## Production mode

```shell
docker-compose -f ./docker-compose.yml up
```

This will create (if not already done) and launch a whole production stack only based on [`docker-compose.yml`](docker-compose.yml):

* No nodejs container (it should not be shipped to production, the development container will be used to create the build artefacts with create-react-app).
* A container for the golang server (with the app compiled)
* An nginx container *TODO*

*This is still a work in progress*