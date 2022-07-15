#!/bin/bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
    VERSION="$(uname -r)"
else
    VERSION=$1
fi

if [[ $# -lt 2 ]]; then
    FW="20191202-97.gite8a0f4c9.el8"
else
    FW=$2
fi

if [[ $# -lt 3 ]]; then
   RHELVER="8.1"
else
   RHELVER=$3
fi

if [[ $# -lt 4 ]]; then
    TAG="rhcos-dbg:$VERSION"
else
    TAG=$4
fi

BUILDER=buildah
which $BUILDER || BUILDER=podman
which $BUILDER || BUILDER=docker
which $BUILDER || BUILDER=""

if [ "$BUILDER" = "" ]; then
    echo "Need to install podman (preferred) or docker"
    exit 1
fi

BUILD_COMMAND="build"

if [ "$BUILDER" = "buildah" ]
then
	BUILD_COMMAND="bud"
fi

$BUILDER $BUILD_COMMAND --build-arg "VERSION=${VERSION}" --build-arg "FW=${FW}" \
	 --build-arg "RHELVER=${RHELVER}" \
         -f Dockerfile -t "${TAG}" || exit 1
#$BUILDER push rhcos-dbg:$VERSION
