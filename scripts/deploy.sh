#!/usr/bin/env bash
set -e

export AWS_DEFAULT_REGION="eu-west-1"

COMMIT="$TRAVIS_COMMIT"
BRANCH="$TRAVIS_BRANCH"
IMAGE_REPO="506127536868.dkr.ecr.eu-west-1.amazonaws.com"
APP="typescript-node-starter"
CONTAINER_NAME="starter"

case "$BRANCH" in
    feature/work-sample)
    export TAG="$BRANCH"
    export ENV="dev"
    export CLUSTER_NAME="typescript-node-starter"
    export domain_name="sandbox.eha.im"
    ;;
esac


if [[ $TRAVIS_PULL_REQUEST == "false" ]]; then
  echo build app image
  docker-compose build app

  $(aws ecr get-login --no-include-email)

  echo tag and push app image
  docker tag $APP "$IMAGE_REPO/$APP-$ENV:latest"
  docker tag $APP "$IMAGE_REPO/$APP-$ENV:$COMMIT"
  docker push "$IMAGE_REPO/$APP-$ENV:latest"
  docker push "$IMAGE_REPO/$APP-$ENV:$COMMIT"

  echo build and push nginx image
  envsubst '${domain_name}' < nginx/nginx.tpl.conf > nginx/nginx.conf
  docker build -t "$IMAGE_REPO/$APP-nginx-$ENV:latest" nginx/.
  docker push "$IMAGE_REPO/$APP-nginx-$ENV:latest"

  echo deploy a new version of the service
  ecs deploy --timeout 900 $CLUSTER_NAME-$ENV $APP -i $CONTAINER_NAME "$IMAGE_REPO/$APP-$ENV:$COMMIT"
fi
