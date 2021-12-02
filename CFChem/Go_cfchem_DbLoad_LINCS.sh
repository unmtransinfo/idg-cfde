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
# LOAD LINCS:
# https://s3.amazonaws.com/lincs-dcic/sigcom-lincs-metadata/LINCS_small_molecules.tsv
SRCDATADIR="$(cd $HOME/../data/LINCS/data; pwd)"
csvfile="$SRCDATADIR/LINCS_small_molecules.tsv"
#
if [ ! -e "${csvfile}" ]; then
	wget -O ${csvfile} https://s3.amazonaws.com/lincs-dcic/sigcom-lincs-metadata/LINCS_small_molecules.tsv
fi
#
TNAME="lincs"
#
psql -d $DBNAME -c "DROP TABLE IF EXISTS $TNAME"
#
#pert_name, target, moa, canonical_smiles, inchi_key, compound_aliases, sig_count
cat $csvfile \
	|${cwd}/../python/csv2sql.py create --tsv \
		--tablename "${TNAME}" --fixtags --maxchar 2000 \
		--colnames "id,pert_name,target,moa,smiles,inchi_key,compound_aliases,sig_count" \
		--coltypes "CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,INT" \
	|psql -d $DBNAME
#
cat $csvfile \
	|${cwd}/../python/csv2sql.py insert --tsv \
		--tablename "${TNAME}" --fixtags --maxchar 2000 \
		--colnames "id,pert_name,target,moa,smiles,inchi_key,compound_aliases,sig_count" \
		--coltypes "CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,INT" \
	|psql -q -d $DBNAME
#
psql -d $DBNAME -c "COMMENT ON TABLE ${TNAME} IS 'LINCS: Small molecules from LINCS Sigcom download'";
#
COLS="pert_name target moa smiles inchi_key compound_aliases"
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
printf "LINCS: N_name:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT pert_name) FROM ${TNAME}" |grep '^[0-9]')
printf "LINCS: N_cansmi:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT cansmi) FROM ${TNAME}" |grep '^[0-9]')
printf "LINCS: N_inchi_key:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT inchi_key) FROM ${TNAME}" |grep '^[0-9]')
#
# DONE LOADING LINCS.
###
#
printf "Elapsed time: %ds\n" "$[$(date +%s) - ${T0}]"
#
