# front

This is the frontend part, based on create-react-app. The CRA readme is accessible [here](README.cra.md).

## Development

Once you `docker-compose up -d`, the whole stack spins up and your webpack server will run inside a container which will expose the port 3000.

npm tasks (such as `npm test`) are run inside the container. To avoid having to write each time `docker-compose exec front npm run my-task`, I added `docker-*` tasks that you can trigger from your host machine.

Task examples:

* `npm run docker-test`: triggers `npm test` in the container from the host
* `npm run docker-build`: triggers `npm run build` in the container from the host

Note: Explain `docker-compose exec <service> <command>`:

* `<service>`: `front`, as described in `docker-compose.yml`
* `<command>`: `npm run my-task`