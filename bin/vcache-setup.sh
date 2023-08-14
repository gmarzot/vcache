#!/bin/bash

# Usage function to display script usage
usage() {
  echo "Usage: $0 [-p|--preserve] [-m|--mgr-addr <manager-address>] [-h|--host <host>] [-k|--mgr-key <mgr-key>] [-c|--cache-mem <cache-memory>] [-b|--bg-build] [-r|--run]"
}

# Parse arguments using getopt
ARGS=$(getopt -o h:m:k:c:pbr -l "host:,mgr-addr:,mgr-key:,cache-mem:,preserve,bg-build,run" -- "$@")

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
    -b | --bg-build)
      bg_build=true
      shift
      ;;
    -r | --run)
      vcache_run=true
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
      exit 2
      ;;
  esac
done

update_env() {
  local VAR="$1"
  local VAL="$2"
  local PRE="$3"

  if [ ! -e .env ]; then
      touch .env
  fi

  # Check if VAR already exists in the .env file
  if grep -q "^$VAR=" .env; then
      if [ -z "${PRE}" ]; then
          sed -i "s/^$VAR=.*/$VAR=${VAL}/" .env
      fi
  else
    echo "$VAR=${VAL}" >> .env
  fi
}

if [ -v cmem ]; then
    update_env "VCACHE_MEM_SIZE" $cmem $preserve
fi
if [ -v host ]; then
    update_env "VCACHE_HOSTNAME" $host $preserve
fi
if [ -v mgr_addr ]; then
    update_env "VCACHE_MGR_ADDR" $mgr_addr $preserve
fi
if [ -v mgr_key ]; then
    update_env "VCACHE_MGR_KEY" $mgr_key $preserve
fi
if [ -r .version ]; then
	VCACHE_VERSION=`cat .version`
    update_env "VCACHE_VERSION" "${VCACHE_VERSION}" $preserve
fi

if [ "$EUID" -eq 0 ]; then
    SUDO=
    type -a docker-compose  > /dev/null

    if [ $? != 0 ]; then
	    echo "unable to find docker-compose on path, please install docker and docker-compose..."
	    exit 3
    fi
else
    SUDO="sudo -E"
    sudo -n docker-compose version 2>/dev/null
    if [ $? != 0 ]; then
        sudo -k docker-compose version
        if [ $? != 0 ]; then
	        echo "unable to execute sudo docker-compose, please provide sudo access..."
	        exit 4
        fi
    fi
fi

logfile=/tmp/vcache-build-$(date '+%Y-%m-%d:%H:%M:%S').log
echo "preparing to build vcache images: ($bg_build) ($vcache_run)" > ${logfile}

if [ -r ".env" ]; then
    source .env
else
    echo "unable to read and source .env file: exiting..."
    exit 5
fi

if [ -v bg_build ]; then
    echo "executing background build ($vcache_run:${VCACHE_SUDO_PW})" >> ${logfile}
    if [ -z "$SUDO" ]; then
        ./bin/vcache-build-run "$vcache_run" >> ${logfile} 2>&1 &
    else
        SUDO_ASKPASS=./bin/vcache-sudo-ask.sh sudo -E -A ./bin/vcache-build-run "$vcache_run" >> ${logfile} 2>&1 &
    fi
    echo "vcache-build-run running in background ($?)" >> ${logfile}
    disown -h >> ${logfile} 2>&1
    echo "vcache-build-run disowned ($?)" >> ${logfile}
else
    $SUDO docker-compose --ansi never build >> ${logfile} 2>&1
    if [ $? != 0 ]; then
	    echo "$SUDO docker-compose build failed($?): see ${logfile} for details"
	    exit 6
    fi

    if [ -v vcache_run ]; then
        echo "preparing to run vcache..." >> ${logfile}
        $SUDO docker-compose --ansi never up -d >> ${logfile} 2>&1
        if [ $? != 0 ]; then
	        echo "$SUDO docker-compose up failed ($?): see ${logfile} for details"
	        exit 7
        fi
    fi
fi

exit 0
