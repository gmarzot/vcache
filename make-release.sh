#!/bin/bash

find . -name '*~' | xargs rm -f
find . -name '#*' | xargs rm -f
find . -name '.#*' | xargs rm -f

rm -f log/*/*.log
rm -f run/*.sock run/uuid.txt  run/*.sock

mkdir release

GIT_REVISION=$(git describe)
echo ${GIT_REVISION} > version.txt

cd ..
mv vivoh-cache vivoh-cache-${GIT_REVISION}
./vivoh-cache-${GIT_REVISION}/makeself.sh --sha256 --nox11 --notemp --tar-extra "--exclude=make* --exclude=.venv --exclude=.npm --exclude=release --exclude=log/* --exclude=run/* --exclude=.git --exclude=.env --exclude=.gitignore ./log ./run" --license LICENSE vivoh-cache-${GIT_REVISION} vivoh-cache-${GIT_REVISION}/release/vivoh-cache-${GIT_REVISION}.run "Vivoh Cache" ./vivoh-cache-setup.sh

mv vivoh-cache-${GIT_REVISION} vivoh-cache
