#!/bin/bash

type -a docker-compose  > /dev/null

if [ $? != 0 ]; then
	echo "unable to find docker-compose, please install docker.io and docker-compose, and provide sudo access..."
	exit 1
fi

sudo docker-compose version

if [ $? != 0 ]; then
	echo "unable to execute sudo docker-compose, please provide sudo access to docker-compose..."
	exit 2
fi

if [[ -d log && -w log ]]; then
	logfile=log/vcache-build-$(date '+%Y-%m-%d:%H:%M:%S').log
	sudo docker-compose build | tee ${logfile}
else
	echo "log directory does not exist, or is not writable..."
	exit 3
fi

if [ $? != 0 ]; then
	echo "sudo docker-compose build failed($?): see ${logfile} for details"
	exit 4
fi

# XXX there must be a better way to grant write perms to containers
chmod ugo+rwx log run etc/varnishstats

exit 0
