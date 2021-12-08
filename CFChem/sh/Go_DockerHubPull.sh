#!/bin/bash
###
#
if [ $(whoami) != "root" ]; then
	echo "${0} should be run as root or via sudo."
	exit
fi
#
INAME="cfchemdb_db"
TAG="latest"
#
DOCKER_ORGANIZATION="unmtransinfo"
#
#
docker pull ${DOCKER_ORGANIZATION}/${INAME}:${TAG}
#
docker image ls
#
