# api

## Development

Once you `docker-compose up -d`, the whole stack spins up and your api server will run inside a container which will expose the port 5000.

## Test

To run the unit tests, run the following command:

```shell
docker-compose run --rm api go test -run ''
```