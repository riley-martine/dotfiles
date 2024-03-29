#!/usr/bin/env bash

set -euxo pipefail

BUILD_DIR=$(mktemp -d)
trap 'rm -rf $BUILD_DIR' EXIT

wget --quiet "https://desktop.docker.com/mac/main/arm64/Docker.dmg" -O "$BUILD_DIR/Docker.dmg"

hdiutil attach "$BUILD_DIR/Docker.dmg"
trap "hdiutil detach /Volumes/Docker" EXIT

sudo rm -rf /Volumes/Docker/Applications/Docker.app

sudo cp -R /Volumes/Docker/Docker.app /Volumes/Docker/Applications/
