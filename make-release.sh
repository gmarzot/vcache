#!/bin/bash

find . -name '*~' | xargs rm -f
find . -name '#*' | xargs rm -f
find . -name '.#*' | xargs rm -f

rm -f log/*/*/log
rm -f run/*.sock run/uuid.txt  run/*.sock
mkdir release

GIT_REVISION=$(git describe)
./makeself.sh --nox11 --notemp --tar-extra "--exclude=make* --exclude=.git --exclude=.gitignore --exclude=.venv --exclude=.npm --exclude=release" . release/vivoh-cache-${GIT_REVISION}.run "Vivoh Video Cache" ./vivoh-cache-setup.sh
