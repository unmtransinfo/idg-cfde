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
# LOAD IDG (compounds):
SRCDATADIR="$(cd $HOME/../data/TCRD/data; pwd)"
csvfile="$SRCDATADIR/tcrd_compounds.tsv"
#
if [ ! -e "${csvfile}" ]; then
	python3 -m BioClients.idg.tcrd.Client listCompounds --o ${csvfile}
fi
#
TNAME="idg"
#
psql -d $DBNAME -c "DROP TABLE IF EXISTS $TNAME"
#
#cmpd_pubchem_cid,smiles,target_count,activity_count
cat $csvfile \
	|${cwd}/../python/csv2sql.py create --tsv \
		--tablename "${TNAME}" --fixtags --maxchar 2000 \
		--colnames "pubchem_cid,smiles,target_count,activity_count" \
		--coltypes "CHAR,CHAR,INT,INT" \
	|psql -d $DBNAME
#
cat $csvfile \
	|${cwd}/../python/csv2sql.py insert --tsv \
		--tablename "${TNAME}" --fixtags --maxchar 2000 \
		--colnames "pubchem_cid,smiles,target_count,activity_count" \
		--coltypes "CHAR,CHAR,INT,INT" \
	|psql -q -d $DBNAME
#
psql -d $DBNAME -c "COMMENT ON TABLE ${TNAME} IS 'IDG-TCRD: Compounds with bioactivity against protein targets'";
#
COLS="pubchem_cid smiles"
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
printf "IDG: N_pubchem_cid:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT pubchem_cid) FROM ${TNAME}" |grep '^[0-9]')
#
###
# Names
# (SLOW, ~1 week)
namefile="$SRCDATADIR/tcrd_compounds_names.tsv"
if [ ! -e "${namefile}" ]; then
	cat $csvfile |sed '1d' |awk -F '\t' '{print $1}' |sort -nu \
		>$SRCDATADIR/tcrd_compounds.cid
	python3 -m BioClients.pubchem.Client get_cid2nicename \
		--i $SRCDATADIR/tcrd_compounds.cid \
		--o ${namefile}
fi
#
psql -d $DBNAME -c "ALTER TABLE ${TNAME} ADD COLUMN name VARCHAR(80)"
N=$[$(cat ${namefile} |wc -l)-1]
i="0"
while [ $i -lt $N ]; do
	i=$[$i + 1]
	line=$(cat ${namefile} |sed '1d' |sed "${i}q;d")
	cid=$(echo "$line" |awk -F '\t' '{print $1}')
	name=$(echo "$line" |awk -F '\t' '{print $2}')
	printf "${i}/${N}. CID=${cid}\tName=\"${name}\"\n"
	psql -d $DBNAME -c "UPDATE ${TNAME} SET name = '${name}' WHERE pubchem_cid = '${cid}'"
done
###
# DONE LOADING IDG.
###
#
printf "Elapsed time: %ds\n" "$[$(date +%s) - ${T0}]"
#
