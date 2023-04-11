#!/bin/bash

type -a docker-compose  > /dev/null

if [ $? != 0 ]; then
	echo "WARNING: vcache requires docker.io and docker-compose. please install these packages before running vcache-start"
fi

sudo docker-compose version

if [ $? != 0 ]; then
	echo "sudo access to docker-compose required, exiting..."
	exit 1
fi

logfile=log/vcache-build-$(date '+%Y-%m-%d:%H:%M:%S').log
sudo docker-compose build | tee ${logfile}

if [ $? != 0 ]; then
	echo "sudo docker-compose build failed($?): see ${logfile} for details"
	exit 2
fi

exit 0
