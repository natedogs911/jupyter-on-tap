#!/bin/bash

# This script downloads both jupyter-base and jupyter repositories
# and build the Jupyter docker container for TAP

JUPYTER_BASE="jupyter-base"
JUPYTER="jupyter"

DOCKER_REPO=$1
if [[ ! -z "$DOCKER_REPO" ]]; then
	JUPYTER_BASE_TAG=$DOCKER_REPO/$JUPYTER_BASE;
	JUPYTER_TAG=$DOCKER_REPO/$JUPYTER;
else
	JUPYTER_BASE_TAG=$JUPYTER_BASE;
	JUPYTER_TAG=$JUPYTER;
fi

# cleanup existing directories
rm -rf ${JUPYTER_BASE}
rm -rf ${JUPYTER}

# download latest repos
git clone https://github.com/trustedanalytics/jupyter-base.git ${JUPYTER_BASE}
pushd ${JUPYTER_BASE}
git submodule update --init --recursive
popd

git clone https://github.com/trustedanalytics/jupyter.git ${JUPYTER}
pushd ${JUPYTER}
git submodule update --init --recursive
popd

# build docker images
if [[ $(env | grep -i http_proxy) ]]; then
	pushd ${JUPYTER_BASE}
	sudo docker build \
		--build-arg HTTP_PROXY=$http_proxy \
		--build-arg HTTPS_PROXY=$http_proxy \
		--build-arg NO_PROXY=$no_proxy \
		--build-arg http_proxy=$http_proxy \
		--build-arg https_proxy=$http_proxy \
		--build-arg no_proxy=$no_proxy \
		--tag=$JUPYTER_BASE_TAG .
	popd
	pushd ${JUPYTER}
	sudo docker build \
		--build-arg HTTP_PROXY=$http_proxy \
		--build-arg HTTPS_PROXY=$http_proxy \
		--build-arg NO_PROXY=$no_proxy \
		--build-arg http_proxy=$http_proxy \
		--build-arg https_proxy=$http_proxy \
		--build-arg no_proxy=$no_proxy \
		--tag=$JUPYTER_TAG .
	popd
else
	pushd ${JUPYTER_BASE}
	sudo docker build --tag=$JUPYTER_BASE_TAG . 
	popd
	pushd ${JUPYTER}
	sudo docker build --tag=$JUPYTER_TAG .
	popd
fi

