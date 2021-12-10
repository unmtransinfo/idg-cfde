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
###
printf "N_mol:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(*) FROM mols" |grep '^[0-9]')
###
# Postprocess molecules table for chemical search functionality.
psql -d $DBNAME -c "DROP INDEX IF EXISTS molidx"
psql -d $DBNAME -c "CREATE INDEX molidx ON mols USING gist(molecule)"
#
### Add FPs to mols table.
# https://www.rdkit.org/docs/GettingStartedInPython.html
# Path-based, Daylight-like.
psql -d $DBNAME -c "ALTER TABLE mols DROP COLUMN IF EXISTS fp"
psql -d $DBNAME -c "ALTER TABLE mols ADD COLUMN fp BFP"
psql -d $DBNAME -c "UPDATE mols SET fp = rdkit_fp(molecule)"
psql -d $DBNAME -c "CREATE INDEX fps_fp_idx ON mols USING gist(fp)"
#
# Morgan (Circular) Fingerprints (with radius=2 ECFP4-like).
psql -d $DBNAME -c "ALTER TABLE mols DROP COLUMN IF EXISTS ecfp"
psql -d $DBNAME -c "ALTER TABLE mols ADD COLUMN ecfp BFP"
psql -d $DBNAME -c "UPDATE mols SET ecfp = morganbv_fp(molecule)"
psql -d $DBNAME -c "CREATE INDEX fps_ecfp_idx ON mols USING gist(ecfp)"
#
###
# Names?
#psql -d $DBNAME -c "UPDATE mols SET name = refmet.refmet_name FROM refmet WHERE refmet.cansmi = mols.cansmi AND mols.cansmi IS NOT NULL"
###
psql -d $DBNAME -c "CREATE ROLE www WITH LOGIN PASSWORD 'foobar'"
psql -d $DBNAME -c "GRANT SELECT ON ALL TABLES IN SCHEMA ${DBSCHEMA} TO www"
psql -d $DBNAME -c "GRANT SELECT ON ALL SEQUENCES IN SCHEMA ${DBSCHEMA} TO www"
psql -d $DBNAME -c "GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA ${DBSCHEMA} TO www"
psql -d $DBNAME -c "GRANT USAGE ON SCHEMA ${DBSCHEMA} TO www"
#
printf "Elapsed time: %ds\n" "$[$(date +%s) - ${T0}]"
#
