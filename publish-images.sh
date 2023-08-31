#!/bin/bash
# publish-images.sh [<arch>] [<version>]

# Load environment variables from .env file if it exists
if [ -r ".env" ]; then
  source .env
fi

ARCH=${1:-amd64}
VERSION=${2:-${VCACHE_VERSION:-0.0.0}}

build_image () {
	local img=${1}
	local ctx=${2:-./context/$img}
	local f=${3}

	if [ -n "$f" ]; then
		f="-f $ctx/$f"
	fi
	
	cmd="sudo docker buildx build $ctx $f --pull --no-cache -t private-registry.vivoh.com/vcache-${img}-${ARCH}:${VERSION} --platform linux/${ARCH}"
	echo -e "\nrunning: $cmd\n"

	$cmd
	
    ret=$?
	if [[ $ret != 0 ]]; then
		echo "failed to build image: $img ($ret)"
	fi
}

push_image () {
	local img=${1}

	cmd="sudo docker push  private-registry.vivoh.com/vcache-${img}-${ARCH}:${VERSION}"

	echo -e "\nrunning: $cmd\n"

	$cmd
	
    ret=$?
	if [[ $ret != 0 ]]; then
		echo "failed to push image: $img ($ret)"
	fi
}

build_image "nginx-fe" "./context" "nginx/Dockerfile.frontend"
build_image "nginx-be" "./context" "nginx/Dockerfile.backend"
build_image "node-red" "./context" "node-red/Dockerfile.release"
build_image "varnish"

push_image "nginx-fe"	
push_image "nginx-be"	
push_image "node-red"	
push_image "varnish"	



