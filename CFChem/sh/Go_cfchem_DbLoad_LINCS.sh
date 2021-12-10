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
# MUST BE STANDARDIZED!!!
###
SRCDATADIR="$(cd $HOME/../data/LINCS/data; pwd)"
# https://s3.amazonaws.com/lincs-dcic/sigcom-lincs-metadata/LINCS_small_molecules.tsv
csvfile_raw="$SRCDATADIR/LINCS_small_molecules.tsv"
#
if [ ! -e "${csvfile_raw}" ]; then
	wget -O ${csvfile_raw} https://s3.amazonaws.com/lincs-dcic/sigcom-lincs-metadata/LINCS_small_molecules.tsv
fi
#
###
if [ ! "$CONDA_EXE" ]; then
	CONDA_EXE=$(which conda)
fi
if [ ! "$CONDA_EXE" -o ! -e "$CONDA_EXE" ]; then
	echo "ERROR: conda not found."
	exit
fi
source $(dirname $CONDA_EXE)/../bin/activate rdkit
python3 -m rdktools.standard.App standardize \
	--i ${csvfile_raw} --smilesColumn 4 --nameColumn 0 \
	--o ${SRCDATADIR}/LINCS_small_molecules_std.smi
# INFO:Mols in: 32471; empty mols in: 0; mols out: 32471; empty mols out: 5515; errors: 5515
###
python3 -m rdktools.util.Cansmi canonicalize \
	--i ${SRCDATADIR}/LINCS_small_molecules_std.smi \
	--o ${SRCDATADIR}/LINCS_small_molecules_std_can.smi
# INFO:Mols in: 32471; empty mols in: 5515; mols out: 32471; empty mols out: 5515; errors: 0
# INFO:Unique CANONICAL SMILES: 10927
conda deactivate
###
# Merge standardized SMILES with data.
csvfile_std="$SRCDATADIR/LINCS_small_molecules_std_can.tsv"
#
${cwd}/../python/merge_smiles_lincs.py \
	${csvfile_raw} \
	${SRCDATADIR}/LINCS_small_molecules_std_can.smi \
	>${csvfile_std}
#
TNAME="lincs"
#
psql -d $DBNAME -c "DROP TABLE IF EXISTS $TNAME"
#
#lcs_id pert_name target moa inchi_key compound_aliases sig_count smiles
cat $csvfile_std \
	|${cwd}/../python/csv2sql.py create --tsv \
		--tablename "${TNAME}" --fixtags --maxchar 2000 \
		--colnames "lcs_id,pert_name,target,moa,inchi_key,compound_aliases,sig_count,smiles" \
		--coltypes "CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,INT,CHAR" \
	|psql -d $DBNAME
#
cat $csvfile_std \
	|${cwd}/../python/csv2sql.py insert --tsv \
		--tablename "${TNAME}" --fixtags --maxchar 2000 \
		--colnames "lcs_id,pert_name,target,moa,inchi_key,compound_aliases,sig_count,smiles" \
		--coltypes "CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,INT,CHAR" \
	|psql -q -d $DBNAME
#
psql -d $DBNAME -c "COMMENT ON TABLE ${TNAME} IS 'LINCS: Small molecules from LINCS Sigcom download'";
#
COLS="lcs_id pert_name target moa cansmi inchi_key compound_aliases"
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
printf "LINCS: N_lcs_id:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT lcs_id) FROM ${TNAME}" |grep '^[0-9]')
printf "LINCS: N_name:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT pert_name) FROM ${TNAME}" |grep '^[0-9]')
printf "LINCS: N_cansmi:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT cansmi) FROM ${TNAME}" |grep '^[0-9]')
printf "LINCS: N_inchi_key:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT inchi_key) FROM ${TNAME}" |grep '^[0-9]')
#
# DONE LOADING LINCS.
###
#
printf "Elapsed time: %ds\n" "$[$(date +%s) - ${T0}]"
#
