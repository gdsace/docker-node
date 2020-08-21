# Archived

This respository is archived and no longer maintained. For node alpine images, use the official node images at https://hub.docker.com/_/node

# Node Containers

[![Build Status](https://travis-ci.org/gdsace/docker-node.svg?branch=master)](https://travis-ci.com/gdsace/docker-node/)

This repository is a collection of Docker images we use internally for node applications both for development and production purposes.

Daily builds are run against these images and automatically sent to our DockerHub repository at:

https://hub.docker.com/r/govtechsg/node/

## Methodology
All runtimes are built from official sources using the methods documented in the runtimes' official documentation.

### Usage/Description
Canonical Tag: `node*-<ENVIRONMENT>-<NODE_VERSION>`
Latest URL: `govtechsg/node*-latest`

ENVIRONMENT can be:
- development: for development purpose, image containing node, npm, yarn and git.
- production: for production purpose, image containing only node and npm.

The `*` is available for versions of Node which satisfy the following criteria:

1. is an LTS release
2. is the latest non-LTS release

## How to use

### Build
The build script creates the build for the specified image. For instance to build image with node 8 for production:

```bash
DH_REPO=govtechsg/node
IMAGE_NAME=node8
NODE_CODE=v8.x
ENVIRONMENT=production ./build.sh "${DH_REPO}" "${IMAGE_NAME}"
```

### Publish
The publish script sends your built image to DockerHub and relies on the build script being run prior to it. For instance to publish a previously built image with node 8 for production:

```bash
DH_REPO=govtechsg/node
IMAGE_NAME=node8
ENVIRONMENT=production ./publish.sh "${DH_REPO}" "${IMAGE_NAME}"
```
