#!/bin/bash

if [[ -f .env && -r .env ]]; then
	echo "using existing .env file..."
	echo "----- .env ----"
	cat .env
	echo ""
	echo "--------------"
else
	echo "generating .env file..."
	read -p "enter the vivoh-cache hostname[$HOSTNAME]: " hostname
	hostname=${hostname:-$HOSTNAME}
	GIT_REVISION=`git describe 2> /dev/null`
	if [[ $? != 0 ]]; then
		echo "[$?]no git revision detected, using 0.0.0 ..."
		GIT_REVISION="0.0.0"
	else
        echo "detected git revision: $GIT_REVISION"
    fi
	echo "HOSTNAME=${hostname}" > .env
	echo "GIT_REVISION=${GIT_REVISION}" >> .env
fi

sudo docker-compose ps --services --filter "status=running" | grep "redis\|mgmt\|backend\|cache\|stats\|frontend" > /dev/null

if [ $? == 0 ]; then
	echo "a vivoh-cache instance is already running..."
	exit 1
fi
echo "cleaning up previous deployment..."
sudo docker-compose down

chmod ugo+rwx run
chmod ugo+rwx etc/varnishstats

echo "starting vivoh-cache..."
sudo docker-compose up -d

if [[ $? != 0 ]]; then
	echo "[$?] an error occured starting vivoh-cache, exiting..."
	exit 2
else
	echo "vivoh-cache started..."
fi

exit 0
