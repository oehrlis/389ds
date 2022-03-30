# Docker based 389 Directory Server

This repository includes all to build and run a Docker based 389 Directory Server.
Whereby the configuration does support cross-platform images in particular for
*ARM64* and *AMD64*. The configuration is based on the official *dscontainer* setup
of *389ds* but does use *Oracle Enterprise Linux 8* as basis image.

The environment is currently still very limited and is constantly being improved.

## Build Docker Image

Local build of an *ARM64* Docker image.

```bash
docker buildx build -f Dockerfile --platform linux/arm64 \
  -t oehrlis/389ds:arm64 --output type=docker .
```

Local build of an *AMD64* Docker image.

```bash
docker buildx build -f Dockerfile --platform linux/amd64 \
  -t oehrlis/389ds:amd64 --output type=docker .
```

Multi-platform build including push to the images to Docker hub.

```bash
docker buildx build -f Dockerfile \
  --platform linux/amd64 --platform linux/arm64 \
  -t oehrlis/389ds --push .
```

## Run 389ds Server

Create a 389ds Directory Server Docker container.

```bash
cd 389ds
docker run -d -p 1389:3389 -p 1636:3636 \
-v "$PWD/dirsrv":/data:z --name 389test oehrlis/389ds:arm64
```

Create a 389ds Directory Server Docker container using *docker-compose*.

```bash
cd 389ds
docker-compose up -d
```

## Configure 389ds Server

On startup just a simple empty instance is created. To use the server it has to
be configured according.

create a suffix and a local backend

```bash
docker exec -it 389ds dsconf localhost backend create \
--suffix dc=trivadislabs,dc=com --be-name userRoot
```

Update the container.inf file

```bash
echo "basedn = dc=trivadislabs,dc=com" >>dirsrv/config/container.inf
```

restart the container

```bash
docker-compose restart
```

Check the available naming Context of the container

```bash
docker exec -it 389ds ldapsearch -h localhost -p 3389 -b "" -x -LLL -s base namingContexts
```
