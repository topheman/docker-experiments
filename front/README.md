# front

This is the frontend part, based on create-react-app. The CRA readme is accessible [here](README.cra.md).

## Development

Once you `docker-compose up -d`, the whole stack spins up and your webpack server will run inside a container which will expose the port 3000.

## Tasks

npm tasks (such as `npm test`) are run inside the container. To avoid having to write each time `docker-compose exec front npm run my-task`, I added `docker-*` tasks that you can trigger from your host machine.

Task examples:

* `npm run docker-test`: triggers `npm test` in the container from the host
* `npm run docker-build`: triggers `npm run build` in the container from the host

Note: Explain `docker-compose exec <service> <command>`:

* `<service>`: `front`, as described in `docker-compose.yml`
* `<command>`: `npm run my-task`

## Miscellaneous

### Proxy

In development mode, we use the create-react-app's [proxy](#proxying-api-requests-in-development) to proxy calls from `/api` to `http://api:5000` (the requests go from the `front` container to the `api` container via the docker subnet, without your host machine having access and are expose on `http://localhost:3000/api`). Check the `proxy` section of the [`package.json`](package.json).