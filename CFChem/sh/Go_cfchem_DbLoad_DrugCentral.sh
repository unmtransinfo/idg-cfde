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
# LOAD DrugCentral:
SRCDATADIR="$(cd $HOME/../data/DrugCentral/data; pwd)"
csvfile="$SRCDATADIR/drugcentral_structures.tsv"
#
if [ ! -e "${csvfile}" ]; then
	python3 -m BioClients.drugcentral.Client list_structures --o ${csvfile}
fi
#
TNAME="drugcentral"
#
psql -d $DBNAME -c "DROP TABLE IF EXISTS $TNAME"
#
# id,name,cas_reg_no,smiles,inchikey,inchi,formula,molweight

cat $csvfile \
	|${cwd}/../python/csv2sql.py create --tsv \
		--tablename "${TNAME}" --fixtags --maxchar 5000 \
		--colnames "id,name,cas_reg_no,smiles,inchikey,inchi,formula,molweight" \
		--coltypes "CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,FLOAT" \
	|psql -d $DBNAME
#
cat $csvfile \
	|${cwd}/../python/csv2sql.py insert --tsv \
		--tablename "${TNAME}" --fixtags --maxchar 5000 \
		--colnames "id,name,cas_reg_no,smiles,inchikey,inchi,formula,molweight" \
		--coltypes "CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,FLOAT" \
	|psql -q -d $DBNAME
#
psql -d $DBNAME -c "COMMENT ON TABLE ${TNAME} IS 'IDG-DrugCentral: Online drug compendium of approved drugs'";
#
COLS="id name cas_reg_no smiles inchikey inchi formula"
for col in $COLS ; do
	psql -d $DBNAME -c "UPDATE ${TNAME} SET $col = NULL WHERE $col = '' OR $col = '-'";
done
#
AddCansmiColumn $DBNAME $TNAME
AddMols $DBNAME $TNAME
#
psql -d $DBNAME -c "ALTER TABLE ${TNAME} ADD COLUMN mol_id INT"
psql -d $DBNAME -c "UPDATE ${TNAME} SET mol_id = m.id FROM mols m WHERE ${TNAME}.cansmi = m.cansmi"
#
printf "IDG: N_cansmi:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT cansmi) FROM ${TNAME}" |grep '^[0-9]')
printf "IDG: N_drugcentral_id:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT id) FROM ${TNAME}" |grep '^[0-9]')
#printf "IDG: N_pubchem_cid:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT pubchem_cid) FROM ${TNAME}" |grep '^[0-9]')
#
# DONE LOADING DrugCentral.
###
#
printf "Elapsed time: %ds\n" "$[$(date +%s) - ${T0}]"
#
