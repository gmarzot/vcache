#!/usr/bin/env bash

SOURCE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd $SOURCE_DIR

if [[ $? != 0 ]]; then
	echo "[$?] unable to cd to source directory..."
	exit 1
fi

mkdir release

GIT_REVISION=$(git describe)

if [[ $? != 0 ]]; then
    echo "[$?] unabl,e to run `git describe`..."
    exit 2
fi

echo -n ${GIT_REVISION} > ./run/vcache-version.txt

cd ..

mv $SOURCE_DIR vcache-${GIT_REVISION}

./vcache-${GIT_REVISION}/makeself.sh --sha256 --nox11 --notemp --tar-extra "--exclude=make* --exclude=.venv --exclude=.npm --exclude=release --exclude=log/* --exclude=uuid.txt --exclude=run/*.pid --exclude=run/*.sock --exclude=.git --exclude=.env --exclude=.gitignore ./log" --license LICENSE vcache-${GIT_REVISION} vcache-${GIT_REVISION}/release/vcache-${GIT_REVISION}.run "VCache Deployment" ./bin/vcache-setup.sh

mv vcache-${GIT_REVISION} $SOURCE_DIR
