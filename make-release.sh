#!/usr/bin/env bash

SOURCE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd $SOURCE_DIR

if [[ $? != 0 ]]; then
	echo "unable to cd to source directory [$SOURCE_DIR] ..."
	exit 1
fi

if [[ ! -d ./release ]]; then
    mkdir release
fi

GIT_REVISION=$(git describe)

if [[ $? != 0 ]]; then
    echo "unable to run `git describe`..."
    exit 2
fi

echo -n ${GIT_REVISION} > ./.version
# this will be included in released images
cp ./.version ./context/node-red/etc/vcache/vcache.version

cd ..

if [[ "${GIT_REVISION}" =~ "^\d+\.\d+\.\d+$" ]]; then
    TARGET_DIR=vcache
else
    TARGET_DIR=vcache-${GIT_REVISION}
fi

if [ "$TARGET_DIR" != "$SOURCE_DIR" ]; then
    if [ -e "$TARGET_DIR" ]; then
        echo "release target directory already exists: $TARGET_DIR"
        exit 3
    fi
    mv $SOURCE_DIR $TARGET_DIR
fi

./${TARGET_DIR}/makeself.sh --sha256 --nox11 --notemp --tar-extra "--exclude=.git --exclude=.env --exclude=.gitignore --exclude=make* --exclude=.npm --exclude=release --exclude=*~" vcache-${GIT_REVISION} ${TARGET_DIR}/release/vcache-${GIT_REVISION}.run "vCache Deployment" ./bin/vcache-setup.sh

if [ "$TARGET_DIR" != "$SOURCE_DIR" ]; then
    mv $TARGET_DIR $SOURCE_DIR
fi
