#!/bin/bash

type -a docker-compose  > /dev/null

if [ $? != 0 ]; then
	echo "WARNING: vivoh-cache requires docker.io and docker-compose. please install these packages before running vivoh-cache-start"
fi

ls -alR

exit 0
