#!/bin/bash

type -a docker-compose  > /dev/null

if [ $? != 0 ]; then
	echo "WARNING: vivoh-cache requires docker.io and docker-compose. please install these packages before running vivoh-cache-start"
fi

sudo docker-compose version

if [ $? != 0 ]; then
	echo "sudo support for docker-compose required..."
	exit 1
fi

logfile=$(date '+%Y-%m-%d:%H:%M:%S')
sudo docker-compose build | tee log/vivoh-cache-build-${logfile}.log

if [ $? != 0 ]; then
	echo "sudo docker-compose build failed($?): see ${logfile} for details"
	exit 2
fi

exit 0
