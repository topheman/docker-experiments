FROM node:10-alpine

ARG NODE_ENV=development
ENV NODE_ENV=$NODE_ENV

RUN cd /usr
RUN mkdir -p front

# Set a working directory
WORKDIR /usr/front

COPY ./package.json .
COPY ./package-lock.json .

RUN npm install

CMD ["npm", "start"]

EXPOSE 3000