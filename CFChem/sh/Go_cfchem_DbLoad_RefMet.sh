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
# Add cansmi column to table.
# N.B.: mol_to_smiles(mol) : returns the canonical SMILES for a molecule.
function AddCansmiColumn {
	dbname=$1
	tname=$2
	psql -d $dbname -c "ALTER TABLE ${tname} ADD COLUMN mol MOL"
	psql -d $dbname -c "ALTER TABLE ${tname} ADD COLUMN cansmi VARCHAR(2000)"
	psql -d $dbname -c "UPDATE ${tname} SET mol = mol_from_smiles(smiles::cstring)"
	psql -d $dbname -c "UPDATE ${tname} SET cansmi = mol_to_smiles(mol)"
	psql -d $dbname -c "ALTER TABLE ${tname} DROP COLUMN mol"
}
###
# Add new molecules to shared mols table from source table.
function AddMols {
	dbname=$1
	tname=$2
	psql -d $dbname <<__EOF__
INSERT INTO
	mols (cansmi, molecule)
SELECT
	${tname}.cansmi, mol_from_smiles(${tname}.cansmi::cstring)
FROM
	${tname}
WHERE
	${tname}.cansmi IS NOT NULL
	AND NOT EXISTS (SELECT cansmi FROM mols WHERE cansmi = ${tname}.cansmi)
	;
__EOF__
}
#
###
# LOAD RefMet:
###
# Columns in refmet.csv.gz:
# 1. "refmet_name"
# 2. "super_class"
# 3. "main_class"
# 4. "sub_class"
# 5. "formula"
# 6. "exactmass"
# 7. "inchi_key"
# 8. "smiles"
# 9. "pubchem_cid"
SRCDATADIR="$(cd $HOME/../data/RefMet; pwd)"
csvfile="$SRCDATADIR/refmet.csv"
if [ ! -e "${csvfile}" ]; then
	wget -O ${csvfile} https://www.metabolomicsworkbench.org/databases/refmet/refmet_download.php
fi
#
TNAME="refmet"
#
psql -d $DBNAME -c "DROP TABLE IF EXISTS $TNAME"
#
cat $csvfile \
	|${cwd}/../python/csv2sql.py create \
		--tablename "${TNAME}" --fixtags --maxchar 2000 \
		--coltypes "CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,INT" \
	|psql -d $DBNAME
#
cat $csvfile \
	|${cwd}/../python/csv2sql.py insert \
		--tablename "${TNAME}" --fixtags --maxchar 2000 \
		--coltypes "CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,INT" \
	|psql -q -d $DBNAME
#
psql -d $DBNAME -c "COMMENT ON TABLE ${TNAME} IS 'RefMet: A Reference list of Metabolite names, from the Metabolomics Workbench'";
#
COLS="smiles refmet_name inchi_key"
for col in $COLS ; do
	psql -d $DBNAME -c "UPDATE ${TNAME} SET $col = NULL WHERE $col = ''";
done
#
AddCansmiColumn $DBNAME $TNAME
AddMols $DBNAME $TNAME
#
psql -d $DBNAME -c "ALTER TABLE ${TNAME} ADD COLUMN mol_id INT"
psql -d $DBNAME -c "UPDATE ${TNAME} SET mol_id = m.id FROM mols m WHERE ${TNAME}.cansmi = m.cansmi"
#
printf "REFMET: N_name:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT refmet_name) FROM ${TNAME}" |grep '^[0-9]')
printf "REFMET: N_cid:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT pubchem_cid) FROM ${TNAME}" |grep '^[0-9]')
printf "REFMET: N_cansmi:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT cansmi) FROM ${TNAME}" |grep '^[0-9]')
#
# DONE LOADING REFMET.
###
#
printf "Elapsed time: %ds\n" "$[$(date +%s) - ${T0}]"
#
