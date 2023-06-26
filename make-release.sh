#!/usr/bin/env bash

SOURCE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd $SOURCE_DIR

if [[ $? != 0 ]]; then
	echo "unable to cd to source directory [$SOURCE_DIR] ..."
	exit 1
fi

mkdir release

GIT_REVISION=$(git describe)

if [[ $? != 0 ]]; then
    echo "unable to run `git describe`..."
    exit 2
fi

echo -n ${GIT_REVISION} > ./.version
# this will be included in released images
echo -n ${GIT_REVISION} > ./context/node-red/etc/vcache/vcache.version

cd ..

mv $SOURCE_DIR vcache-${GIT_REVISION}

./vcache-${GIT_REVISION}/makeself.sh --sha256 --nox11 --notemp --tar-extra "--exclude=.git --exclude=.gitignore --exclude=make* --exclude=.npm --exclude=release --exclude=*~" --license LICENSE vcache-${GIT_REVISION} vcache-${GIT_REVISION}/release/vcache-${GIT_REVISION}.run "vCache Deployment" ./bin/vcache-setup.sh

mv vcache-${GIT_REVISION} $SOURCE_DIR
