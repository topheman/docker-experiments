FROM golang:alpine

# inspired by https://github.com/McMenemy/GoDoRP/blob/master/api/Dockerfile

# if left blank app will run with dev settings
# to build production image run:
# $ docker build ./api --build-args app_env=production
ARG app_env
ENV APP_ENV $app_env

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
CMD if [ ${APP_ENV} = production ]; \
	then \
	api; \
	else \
	go get github.com/pilu/fresh && \
	fresh; \
	fi

EXPOSE 5000