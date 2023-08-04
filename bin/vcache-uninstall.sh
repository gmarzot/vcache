#!/bin/bash

# Usage function to display script usage
usage() {
  echo "Usage: $0 [-r|--real-clean]"
}

# Parse arguments using getopt
ARGS=$(getopt -o r -l "real-clean" -- "$@")

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

# Get the full path of the vCache installion dir
SOURCE_DIR="$(dirname $(dirname $(realpath $0)))"

echo "uninstalling vCache from: ${SOURCE_DIR} ($real_clean)"

cd ${SOURCE_DIR}

if [ $? != 0 ]; then
    echo "unable to cd to vCache installations dir: ${SOURCE_DIR}: exiting..."
    exit 1
fi

STOP_SCRIPT="./bin/vcache-stop"

if [ ! -x $STOP_SCRIPT ]; then
    echo "unable to execute vCache stop script: $STOP_SCRIPT: exiting..."
    exit 2
fi

STOP_ARG=
if [ -v real_clean ]; then
    $STOP_ARG="-r"
fi

$STOP_SCRIPT $STOP_ARG

if [ $? != 0 ]; then
    echo "error while running vCache stop: $STOP_SCRIPT $STOP_ARG ($?): exiting..."
    exit 3
fi

cd ..

if [ $? != 0 ]; then
    echo "unable to cd to vCache install parent dir: ${SOURCE_DIR}/..: exiting..."
    exit 4
fi

if [[ "${SOURCE_DIR}" == *'vcache'* ]]; then
    sudo rm -rf ${SOURCE_DIR}
else
    echo "source directory does not look like a vCache install: ${SOURCE_DIR}"
    false
fi

if [ $? != 0 ]; then
    echo "unable to rm vCache install dir: ${SOURCE_DIR}: exiting..."
    exit 5
fi

echo "vCache uninstalled!"

exit 0

