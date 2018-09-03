#!/bin/sh
CURR_DIR=$(dirname $0);
IMAGE_URL=$1
IMAGE_TAG=$2;
BUILD_ARGS=$3;

if [ "${IMAGE_URL}" = "" ]; then
  printf "\n\e[31m\e[1m[!] Specify the namespace to build as the first argument.\e[0m\n";
  exit 1;
fi;

if [ "${IMAGE_TAG}" = "" ]; then
  printf "\n\e[31m\e[1m[!] Specify the image tag to build as the second argument.\e[0m\n";
  exit 1;
fi;

ADDITIONAL_BUILD_ARGS=""
if [ "${BUILD_ARGS}" != "" ]; then
  ADDITIONAL_BUILD_ARGS="$(echo "${BUILD_ARGS}" | sed -e $'s|,|\\\n|g' | xargs -I @ echo '--build-arg @')";
fi;

TAG="${IMAGE_URL}:${IMAGE_TAG}-${ENVIRONMENT}-next";

docker build \
  ${ADDITIONAL_BUILD_ARGS} \
  --file ./${ENVIRONMENT}.Dockerfile \
  --tag "${TAG}" \
  .;