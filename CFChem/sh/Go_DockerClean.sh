#!/bin/bash
###
#
if [ $(whoami) != "root" ]; then
	echo "${0} should be run as root or via sudo."
	exit
fi
#
###
INAME="cfchemdb_db"
CNAME="${INAME}_container"
#
docker stop ${CNAME}
docker rm ${CNAME}
docker rmi ${INAME}
#
IIDS=$(docker images -f dangling=true \
	|sed -e '1d' \
	|awk -e '{print $3}')
for iid in $IIDS ; do
	docker image rm ${iid}
done
#
docker image ls -a
#
docker container ls -a
#
