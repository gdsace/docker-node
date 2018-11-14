#!/bin/sh
IMAGE_URL=$1
IMAGE_TAG=$2;

TAG="${IMAGE_URL}:${IMAGE_TAG}-${ENVIRONMENT}-next";
TAG_LATEST="${IMAGE_URL}:${IMAGE_TAG}-${ENVIRONMENT}-latest";

VERSIONS=$(docker run --entrypoint="version-info" ${TAG});
VERSION_NODE=$(printf "${VERSIONS}" | grep -e 'node:' | cut -f 2 -d ':');
VERSION_NODE_MAJOR=$(printf "${VERSIONS}" | grep -e 'node_major:' | cut -f 2 -d ':');
VERSION_NODE_MINOR=$(printf "${VERSIONS}" | grep -e 'node_minor:' | cut -f 2 -d ':');
VERSION_NODE_PATCH=$(printf "${VERSIONS}" | grep -e 'node_patch:' | cut -f 2 -d ':');
VERSION_NPM=$(printf "${VERSIONS}" | grep npm | cut -f 2 -d ':');
VERSION_YARN=$(printf "${VERSIONS}" | grep yarn | cut -f 2 -d ':');
if [ "$ENVIRONMENT" = "production" ]; then
  EXISTENCE_TAG="node-${VERSION_NODE}_npm-${VERSION_NPM}";
else
  EXISTENCE_TAG="node-${VERSION_NODE}_npm-${VERSION_NPM}_yarn-${VERSION_YARN}";
fi
EXISTENCE_REPO_URL="${IMAGE_URL}:${IMAGE_TAG}-${ENVIRONMENT}-${EXISTENCE_TAG}";
NODE_VERSION_REPO_URL="${IMAGE_URL}:${IMAGE_TAG}-${ENVIRONMENT}-${VERSION_NODE}";

printf "Checking existence of [${EXISTENCE_REPO_URL}]...";
$(docker pull ${EXISTENCE_REPO_URL}) && EXISTS=$?;
if [ "${EXISTS}" != "0" ] || [ -z "${COMMIT_MESSAGE##*'[force build]'*}" ]; then
  printf "[${EXISTENCE_REPO_URL}] not found. Pushing new image...\n";
  printf "Pushing [${TAG_LATEST}]... ";
  docker tag ${TAG} ${TAG_LATEST};
  docker push ${TAG_LATEST};
  printf "Pushing [${EXISTENCE_REPO_URL}]... ";
  docker tag ${TAG} ${EXISTENCE_REPO_URL};
  docker push ${EXISTENCE_REPO_URL};
  printf "Pushing [${NODE_VERSION_REPO_URL}]... ";
  docker tag ${TAG} ${NODE_VERSION_REPO_URL};
  docker push ${NODE_VERSION_REPO_URL};
else
  printf "[${EXISTENCE_REPO_URL}] found. Skipping push.\n";
  echo exists;
fi;