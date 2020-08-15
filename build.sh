#!/bin/bash


VAR=gpu-cv

echo $VAR

  docker build \
    --build-arg CONFIG=$VAR \
    --build-arg ADDITIONAL_PACKAGES="libopencv-dev" \
    --build-arg SOURCE_BRANCH=$SOURCE_BRANCH \
    --build-arg SOURCE_COMMIT=$SOURCE_COMMIT .
