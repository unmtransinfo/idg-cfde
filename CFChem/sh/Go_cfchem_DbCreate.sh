#!/bin/bash
###
# https://www.rdkit.org/docs/Cartridge.html
###
#
T0=$(date +%s)
#
DBNAME="cfchemdb"
DBSCHEMA="public"
DBHOST="localhost"
#
cwd=$(pwd)
#
dropdb $DBNAME
createdb $DBNAME
psql -d $DBNAME -c "COMMENT ON DATABASE $DBNAME IS 'CFChemDb: Common Fund Data Ecosystem (CFDE) Chemical Database'";
###
# Create mols table for RDKit structural searching.
#sudo -u postgres psql -d $DBNAME -c 'CREATE EXTENSION rdkit'
psql -d $DBNAME -c 'CREATE EXTENSION rdkit'
#
# Molecules table:
psql -d $DBNAME <<__EOF__
CREATE TABLE mols (
	id SERIAL PRIMARY KEY,
	name VARCHAR(100),
	cansmi VARCHAR(2000),
	molecule MOL
	);
__EOF__
#
# Metadata table:
psql -d $DBNAME <<__EOF__
CREATE TABLE meta (
	field VARCHAR(18) PRIMARY KEY,
	value VARCHAR(100),
	description VARCHAR(2000)
	);
__EOF__
###
#
printf "Elapsed time: %ds\n" "$[$(date +%s) - ${T0}]"
#
