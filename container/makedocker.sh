#!/bin/sh

DIR=$(dirname $0)

TAG="1.0.0"
REPO="crukcibioinformatics/mgareferencebuilder:$TAG"

# Can't do this in the Dockerfile.
cp $DIR/../java/target/mga-referencebuilder-*.jar $DIR/mga-referencebuilder.jar

sudo docker build --tag "$REPO" --file Dockerfile .
if [ $? -eq 0 ]
then
    sudo docker push "$REPO"
fi
