#!/bin/bash

# Usage function to display script usage
usage() {
  echo "Usage: $0 [-r|--real-clean]"
}

# Parse arguments using getopt
ARGS=$(getopt -o Ar -l "no-ansi,real-clean" -- "$@")

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
    -A | --no-ansi)
      no_ansi=true
      shift
      ;;
    -r | --real-clean)
      real_clean=true
      shift
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

# Get the full path of the vcache installion dir
SOURCE_DIR="$(dirname $(dirname $(realpath $0)))"

echo "uninstalling vcache from: ${SOURCE_DIR} ($real_clean)"

cd ${SOURCE_DIR}

if [ $? != 0 ]; then
    echo "unable to cd to vcache installations dir: ${SOURCE_DIR}: exiting..."
    exit 1
fi

STOP_SCRIPT="./bin/vcache-stop"

if [ ! -x $STOP_SCRIPT ]; then
    echo "unable to execute vcache stop script: $STOP_SCRIPT: exiting..."
    exit 2
fi

STOP_ARG=
if [ -v real_clean ]; then
    STOP_ARG="-r"
fi

if [ -v no_ansi ]; then
    STOP_ARG="${STOP_ARG} -A"
fi

$STOP_SCRIPT $STOP_ARG

if [ $? != 0 ]; then
    echo "error while running vcache stop: $STOP_SCRIPT $STOP_ARG ($?): exiting..."
    exit 3
fi

cd ..

if [ $? != 0 ]; then
    echo "unable to cd to vcache install parent dir: ${SOURCE_DIR}/..: exiting..."
    exit 4
fi

if [[ "${SOURCE_DIR}" == *'vcache'* ]]; then
    sudo rm -rf ${SOURCE_DIR}
else
    echo "source directory does not look like a vcache install: ${SOURCE_DIR}"
    false
fi

if [ $? != 0 ]; then
    echo "unable to rm vcache install dir: ${SOURCE_DIR}: exiting..."
    exit 5
fi

echo "vcache uninstalled!"

exit 0

