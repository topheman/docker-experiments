FROM golang:1.10.3-alpine as builder

# Volumes and commands may be overriden in docker-compose*.yml files.
# To build the image in production mode without docker-compose, run:
# `docker build ./api -t topheman/docker-experiments_api_production`
# `docker run -d -p 5000:5000 topheman/docker-experiments_api_production`
ENV APP_ENV "development"

# alpine comes without git. We need it for go get
RUN apk update && apk upgrade && apk add --no-cache git

COPY . /go/src/github.com/topheman/docker-experiments/api
WORKDIR /go/src/github.com/topheman/docker-experiments/api

RUN go get -v ./
RUN go build

# With the following target, we create a small image for production:
# - no need for golang compiler / tools
# - only copy the binary that was compiled at the previous step
# We don't use this target in development
# Infos: https://medium.com/@chemidy/create-the-smallest-and-secured-golang-docker-image-based-on-scratch-4752223b7324

FROM alpine as production

ENV APP_ENV "production"

COPY --from=builder /go/bin/api /usr/bin/api

CMD echo "production"; api

# The Dockerfile should still be usable without docker-compose, so, by default,
# it's a production image, the CMD will run the binary that was compiled
# If you create a development image, the `command` specified in the docker-compose.override.yml
# will override and use pilu/fresh which manages building and restarting dev server when sources change
# Infos: https://medium.com/@craigchilds94/hot-reloading-go-programs-with-docker-glide-fresh-d5f1acb63f72

# CMD echo "APP_ENV=$APP_ENV"; \
# 	if [ "$APP_ENV" = "production" ]; \
# 	then \
# 	api; \
# 	else \
# 	go get github.com/pilu/fresh && \
# 	fresh; \
# 	fi

EXPOSE 5000