#!/bin/bash
###
# Instantiate and run containers.
# -dit = --detached --interactive --tty
###
set -e
#
if [ $(whoami) != "root" ]; then
	echo "${0} should be run as root or via sudo."
	exit
fi
#
cwd=$(pwd)
#
#VTAG="latest"
VTAG="v1.0.0"
#
###
# PostgreSQL db
INAME_DB="cfchemdb_db"
#
APPPORT_DB=5432
DOCKERPORT_DB=5442
#
docker run -dit \
	--name "${INAME_DB}_container" \
	-p ${DOCKERPORT_DB}:${APPPORT_DB} \
	unmtransinfo/${INAME_DB}:${VTAG}
#
docker container logs "${INAME_DB}_container"
#
###
NSEC="60"
echo "Sleep ${NSEC} seconds while db server starting up..."
sleep $NSEC
###
# Test db before proceeding.
docker exec "${INAME_DB}_container" sudo -u postgres psql -l
docker exec "${INAME_DB}_container" sudo -u postgres psql -d cfchemdb -c "SELECT table_name FROM information_schema.tables WHERE table_schema='public'"
###
#
###
docker container ls -a
#
printf "CFChemDb PostgreSQL Endpoint: localhost:${DOCKERPORT_DB}\n" 
#
#
