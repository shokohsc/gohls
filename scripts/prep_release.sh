#!/bin/bash
set -xeuo pipefail

export VERSION=$1
export TIME=$(date +%s)

if [ -z "$VERSION" ]; then
	echo "You must call this script with a version as first argument"
	exit 1
fi

cd ui/src && npm i && npm run build && cd ../../

rm -rf build
mkdir build

go generate github.com/shokohsc/gohls/internal/api

function make_release() {
	NAME=$1
	export GOOS=$2
	export GOARCH=$3
	SUFFIX=$4
	RELEASE_PATH=build/gohls-$NAME-${VERSION}
	RELEASE_FILE=gohls-$NAME-${VERSION}.tar.gz
	mkdir $RELEASE_PATH
	cp README.md $RELEASE_PATH
	cp LICENSE.txt $RELEASE_PATH
	echo $GOOS
	echo $GOARCH
	cat internal/buildinfo/buildinfo.go.in | sed "s/##VERSION##/${VERSION}/g" | sed "s/##COMMIT##/$(git rev-parse HEAD)/g" | sed "s/##BUILD_TIME##/$TIME/g" > internal/buildinfo/buildinfo.go
	go build -o $RELEASE_PATH/gohls${SUFFIX} *.go
	PREV_WD=$(pwd)
	cd  $RELEASE_PATH
	tar cvfz ../$RELEASE_FILE .
	cd ../../
}

# make_release "osx" "darwin" "amd64" ""
# make_release "osx-arm64" "darwin" "arm64" ""
# make_release "linux-386" "linux" "386" ""
make_release "linux-amd64" "linux" "amd64" ""
make_release "linux-arm64" "linux" "arm64" ""
# make_release "windows-amd64" "windows" "amd64" ".exe"