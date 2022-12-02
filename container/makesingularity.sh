#!/bin/sh

TAG="latest"
REPO="crukcibioinformatics/mgareferencebuilder:$TAG"
SIF="mgareferencebuilder-$TAG.sif"

sudo rm -f mgareferencebuilder*.sif

sudo singularity build "$SIF" docker-daemon://${REPO}
sudo chown $USER "$SIF"
chmod a-x "$SIF"

