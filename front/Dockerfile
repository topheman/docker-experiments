FROM node:10-alpine

ARG NODE_ENV=development
ENV NODE_ENV=$NODE_ENV

RUN cd /usr
RUN mkdir -p front

# Set a working directory
WORKDIR /usr/front

# copy local yarn version
COPY ./bin/ ./bin/
COPY ./.yarnrc .

COPY ./package.json .
COPY ./yarn.lock .

RUN yarn

CMD ["npm", "start"]

EXPOSE 3000