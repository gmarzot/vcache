#!/bin/bash

# Default values
host=$(hostname)
cmem=4G
mgr_addr=""
mgr_key=""

# Usage function to display script usage
usage() {
  echo "Usage: $0 [-p|--preserve] [-m|--mgr-addr <manager-address>] [-h|--host <host>] [-k|--mgr-key <mgr-key>] [-c|--cache-mem <cache-memory>]"
}

# Parse arguments using getopt
ARGS=$(getopt -o pk:m:h:C: -l "mgr-addr:,host:" -- "$@")

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
    -p | --preserve)
      preserve=true
      shift
      ;;
    -h | --host)
      host="$2"
      shift 2
      ;;
    -c | --cache-mem)
      cmem="$2"
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

if [ -r ".env" ]; then
    source .env
fi

update_env() {
  local VAR="$1"
  local VAL="$2"
  local PRE="$3"

  # Check if VAR already exists in the .env file
  if grep -q "^$VAR=" .env; then
      if [ -z "${PRE}" ]; then
          sed -i "s/^$VAR=.*/$VAR=${VAL}/" .env
      fi
  else
    echo "$VAR=${VAL}" >> .env
  fi
}

update_env "VCACHE_MEM_SIZE" $cmem $preserve
update_env "VCACHE_HOSTNAME" $host $preserve
update_env "VCACHE_MGR_ADDR" $mgr_addr $preserve
update_env "VCACHE_MGR_KEY" $mgr_key $preserve

logfile=/tmp/vcache-build-$(date '+%Y-%m-%d:%H:%M:%S').log
sudo docker-compose build | tee ${logfile}

if [ $? != 0 ]; then
	echo "sudo docker-compose build failed($?): see ${logfile} for details"
	exit 4
fi

exit 0
