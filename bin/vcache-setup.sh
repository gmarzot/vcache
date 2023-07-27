#!/bin/bash

# Default values
mgr_addr=""
host=$(hostname)

# Usage function to display script usage
usage() {
  echo "Usage: $0 [-f|--force] [-m|--mgr-addr <manager_address>] [-h|--host <host>] [-k|--mgr-key <mgr-key>]"
}

# Parse arguments using getopt
ARGS=$(getopt -o m:h: -l "mgr-addr:,host:" -- "$@")

# Check for any parsing errors
if [ $? -ne 0 ]; then
  usage
  exit 1
fi

# Evaluate arguments set by getopt
eval set -- "$ARGS"

# Loop through the arguments and set variables accordingly
while true; do
  case "$1" in
    -f | --force)
      force=true
      shift
      ;;
    -h | --host)
      host="$2"
      shift 2
      ;;
    -m | --mgr-addr)
      mgr_addr="$2"
      shift 2
      ;;
    -k | --mgr-key)
      mgr_key="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

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

if [ -r ".env" && ]; then
    source .env
fi

update_env_file() {
  local VAR="$1"
  local VAL="$2"
  local FORCE="$3"

  # Check if VAR already exists in the .env file
  if grep -q "^$VAR=" .env; then
    # Update the value if force is true
    if [ "$FORCE" = true ]; then
      sed -i "s/^$VAR=.*/$VAR=${VAL}/" .env
    fi
  else
    # Add the entry if VAR is not present
    echo "$VAR=${VAL}" >> .env
  fi
}

update_env("VCACHE_HOSTNAME",$host,$force)
update_env("VCACHE_MGR_ADDR",$mgr_addr,$force)
if [ -n "${mgr_key+x}" ]; then
    update_env("VCACHE_MGR_KEY",$mgr_key,$force)
fi

logfile=/tmp/vcache-build-$(date '+%Y-%m-%d:%H:%M:%S').log
sudo docker-compose build | tee ${logfile}

if [ $? != 0 ]; then
	echo "sudo docker-compose build failed($?): see ${logfile} for details"
	exit 4
fi

exit 0
