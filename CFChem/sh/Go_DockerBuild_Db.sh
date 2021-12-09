#!/bin/bash
###
# Takes ~5-20min, depending on server, mostly pg_restore.
###
#
set -e
#
if [ $(whoami) != "root" ]; then
	echo "${0} should be run as root or via sudo."
	exit
fi
#
cwd=$(pwd)
#
DBNAME="cfchemdb"
#
docker version
#
INAME="${DBNAME}_db"
TAG="latest"
#
if [ ! -e "${cwd}/data" ]; then
	mkdir ${cwd}/data/
fi
#
sudo -u postgres psql -d ${DBNAME} -c "ALTER TABLE idg OWNER TO postgres"
sudo -u postgres psql -d ${DBNAME} -c "ALTER TABLE drugcentral OWNER TO postgres"
sudo -u postgres psql -d ${DBNAME} -c "ALTER TABLE lincs OWNER TO postgres"
sudo -u postgres psql -d ${DBNAME} -c "ALTER TABLE refmet OWNER TO postgres"
sudo -u postgres psql -d ${DBNAME} -c "ALTER TABLE glygen OWNER TO postgres"
sudo -u postgres psql -d ${DBNAME} -c "ALTER TABLE reprotox OWNER TO postgres"
#
dumpfile="/home/data/CFDE/CFChemDb/${DBNAME}.pgdump"
if [ ! -e "${dumpfile}" ]; then
	sudo -u postgres pg_dump --no-owner --no-privileges --format=custom -d ${DBNAME} >${dumpfile}
fi
cp ${dumpfile} ${cwd}/data/
#
T0=$(date +%s)
#
###
# Build image from Dockerfile.
dockerfile="${cwd}/Dockerfile_Db"
docker build -f ${dockerfile} -t ${INAME}:${TAG} .
#
printf "Elapsed time: %ds\n" "$[$(date +%s) - ${T0}]"
#
rm -f ${cwd}/data/${DBNAME}.pgdump
#
docker images
#
