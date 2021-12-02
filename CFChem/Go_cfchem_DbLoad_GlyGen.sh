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
# LOAD GlyGen:
###
SRCDATADIR="$(cd $HOME/../data/GlyGen/data; pwd)"
csvfile="$SRCDATADIR/glygen.tsv"
#glycan_type,mass_pme,number_monosaccharides,fully_determined,wurcs,byonic,glytoucan_ac,missing_score,glycam,inchi,gwb,glycoct,iupac,smiles_isomeric,mass,_id,inchi_key,glytoucan_id,pubchem_cid,pubchem_sid,chebi_id
# wurcs may be >2000 chars.
#
if [ ! -e "${csvfile}" ]; then
	python3 -m BioClients.glygen.Client list_glycans --o ${csvfile}
fi
#
TNAME="glygen"
#
psql -d $DBNAME -c "DROP TABLE IF EXISTS $TNAME"
#
cat $csvfile \
	|${cwd}/../python/csv2sql.py create \
		--tsv --tablename "${TNAME}" --fixtags --maxchar 5000 \
		--colnames "glycan_type,mass_pme,number_monosaccharides,fully_determined,wurcs,byonic,glytoucan_ac,missing_score,glycam,inchi,gwb,glycoct,iupac,smiles,mass,glygen_id,inchi_key,glytoucan_id,pubchem_cid,pubchem_sid,chebi_id" \
		--coltypes "CHAR,FLOAT,INT,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,FLOAT,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR" \
	|psql -d $DBNAME
#
cat $csvfile \
	|${cwd}/../python/csv2sql.py insert \
		--tsv --tablename "${TNAME}" --fixtags --maxchar 5000 \
		--colnames "glycan_type,mass_pme,number_monosaccharides,fully_determined,wurcs,byonic,glytoucan_ac,missing_score,glycam,inchi,gwb,glycoct,iupac,smiles,mass,glygen_id,inchi_key,glytoucan_id,pubchem_cid,pubchem_sid,chebi_id" \
		--coltypes "CHAR,FLOAT,INT,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,FLOAT,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR" \
	|psql -q -d $DBNAME
#
psql -d $DBNAME -c "COMMENT ON TABLE ${TNAME} IS 'GlyGen: Computational and Informatics Resources for Glycoscience'";
#
COLS="glycan_type fully_determined wurcs byonic glytoucan_ac missing_score glycam inchi gwb glycoct iupac smiles glygen_id"
#
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
printf "GLYGEN: N_glygen_id:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT glygen_id) FROM ${TNAME}" |grep '^[0-9]')
printf "GLYGEN: N_inchi:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT inchi) FROM ${TNAME}" |grep '^[0-9]')
printf "GLYGEN: N_cansmi:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT cansmi) FROM ${TNAME}" |grep '^[0-9]')
#
# DONE LOADING GLYGEN.
###
#
printf "Elapsed time: %ds\n" "$[$(date +%s) - ${T0}]"
#
