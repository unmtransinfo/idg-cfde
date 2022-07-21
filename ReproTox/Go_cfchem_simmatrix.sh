#!/bin/bash
###
# Db pw in ~/.pgpass
###
#
cwd=$(pwd)
#
###
DBNAME="cfchemdb"
DBHOST="unmtid-dbs.net"
DBPORT="5442"
DBUSR="commoner"
#
###
#
(cat reprotox_simmatrix.sql \
	|psql -qAF $'\t' -h $DBHOST -p $DBPORT -d $DBNAME -U $DBUSR \
	|sed -e '/^([0-9]* rows)$/d' \
	) >${cwd}/output/reprotox_simmatrix.tsv
#
