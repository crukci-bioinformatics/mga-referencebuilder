#!/bin/sh

TAG="latest"
REPO="crukcibioinformatics/referencebuilder:$TAG"

sudo docker build --tag "$REPO" --file Dockerfile .
#sudo docker push "$REPO"
