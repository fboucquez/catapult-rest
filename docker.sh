#!/bin/sh

if [ "${DOCKER_IMAGE_NAME}" = "" ]
then
  echo "Docker deployment ignored env DOCKER_IMAGE_NAME has not been provided"
  exit;
fi

if [ ! "${DOCKER_PASSWORD}" = "" ]
then
  echo "Login into docker..."
  echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
fi

cd rest
CURRENT_VERSION=$(npm run version --silent)
cd ..

if [ "$1" = "--release" ]
then
   VERSION="${CURRENT_VERSION}"
else
   VERSION="${CURRENT_VERSION}-alpha"
fi

echo "Creating image ${DOCKER_IMAGE_NAME}:${VERSION}"
docker build -t "${DOCKER_IMAGE_NAME}:${VERSION}" .
docker images

# Quick test, the expected error is ENOENT: no such file or directory, open '../resources/rest.json'
echo "Testing image ${DOCKER_IMAGE_NAME}:${VERSION}. NOTE: ENOENT: no such file or directory, open '../resources/rest.json is expected"
docker run --rm "${DOCKER_IMAGE_NAME}:${VERSION}" npm start

echo "Pushing image ${DOCKER_IMAGE_NAME}:${VERSION}"
docker push "${DOCKER_IMAGE_NAME}:${VERSION}"