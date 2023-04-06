#!/bin/bash

find . -name '*~' | xargs rm -f
find . -name '#*' | xargs rm -f
find . -name '.#*' | xargs rm -f

rm -f log/*/*/log
rm -f run/*.sock run/uuid.txt  run/*.sock
mkdir release

GIT_REVISION=$(git describe)

cd ..
mv vivoh-cache vivoh-cache-${GIT_REVISION}
./vivoh-cache-${GIT_REVISION}/makeself.sh --nox11 --notemp --tar-extra "--exclude=make* --exclude=.venv --exclude=.npm --exclude=release --exclude=log/* --exclude=run/* --exclude=.git --exclude=.gitignore ./log ./run" --license LICENSE vivoh-cache-${GIT_REVISION} vivoh-cache-${GIT_REVISION}/release/vivoh-cache-${GIT_REVISION}.run "Vivoh Video Cache" ./vivoh-cache-setup.sh

mv vivoh-cache-${GIT_REVISION} vivoh-cache
