#!/bin/bash

type -a docker-compose  > /dev/null

if [ $? != 0 ]; then
	echo "unable to find docker-compose, please install docker.io and docker-compose, and provide sudo access..."
	exit 1
fi

sudo docker-compose version

if [ $? != 0 ]; then
	echo "unable to execute sudo, please provide sudo access to docker-compose..."
	exit 2
fi

logfile=/tmp/vcache-build-$(date '+%Y-%m-%d:%H:%M:%S').log
sudo docker-compose build | tee ${logfile}

if [ $? != 0 ]; then
	echo "sudo docker-compose build failed($?): see ${logfile} for details"
	exit 4
fi

exit 0
