# front

This is the frontend part, based on create-react-app. The CRA readme is accessible [here](README.cra.md).

## Development

Once you `docker-compose up -d`, the whole stack spins up and your webpack server will run inside a container which will expose the port 3000.

## Tasks

npm tasks (such as `npm test`) are run inside the container. To avoid having to write each time `docker-compose run front npm run my-task`, I added `docker-*` tasks that you can trigger from your host machine:

* `npm run docker-test`: runs all tests in a container
* `npm run docker-test:unit`: runs all unit tests in a container
* `npm run docker-test:unit:watch`: runs all unit tests in a container in watch mode
* `npm run docker-build`: runs `npm run build` in a container (which will create the `./build` folder on the host machine)

## Miscellaneous

### Proxy

In development mode, we use the create-react-app's [proxy](#proxying-api-requests-in-development) to proxy calls from `/api` to `http://api:5000` (the requests go from the `front` container to the `api` container via the docker subnet, without your host machine having access and are expose on `http://localhost:3000/api`). Check the `proxy` section of the [`package.json`](package.json).