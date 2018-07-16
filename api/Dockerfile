FROM golang:alpine

# inspired by https://github.com/McMenemy/GoDoRP/blob/master/api/Dockerfile

# APP_ENV is injected via docker-compose from de .yml config files
# `docker-compose up` will create and launch the whole stack in development mode
# To build the image in production mode without docker-compose, run:
# `docker build ./api --build-arg APP_ENV=production -t my-docker-fullstack-project_api_production`
ARG APP_ENV
ENV APP_ENV $APP_ENV
RUN echo "Building in mode: $APP_ENV"

# alpine comes without git. We need it for go get
RUN apk update && apk upgrade && apk add --no-cache git

COPY . /go/src/github.com/topheman/my-docker-fullstack-project/api
WORKDIR /go/src/github.com/topheman/my-docker-fullstack-project/api

# todo which package manager use ? godep, glide ...?
# RUN go get -v github.com/gorilla/mux

RUN go get -v ./
RUN go build

# if dev setting will use pilu/fresh for code reloading via docker-compose volume sharing with local machine
# if production setting will build binary
# More infos: https://medium.com/@craigchilds94/hot-reloading-go-programs-with-docker-glide-fresh-d5f1acb63f72
# 
# Note: is this still the best solution ?
CMD echo "APP_ENV=$APP_ENV"; \
	if [ "$APP_ENV" = "production" ]; \
	then \
	api; \
	else \
	go get github.com/pilu/fresh && \
	fresh; \
	fi

EXPOSE 5000