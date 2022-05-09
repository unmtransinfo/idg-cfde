#!/bin/bash
###
# Check CFChemDb for all compounds from KG.
###
#
T0=$(date +%s)
#
cwd=$(pwd)
DATADIR="${cwd}/data"
#
###
if [ ! "$CONDA_EXE" ]; then
	CONDA_EXE=$(which conda)
fi
if [ ! "$CONDA_EXE" -o ! -e "$CONDA_EXE" ]; then
	echo "ERROR: conda not found."
	exit
fi
#
# 
smifile="$DATADIR/ReproTox_kg_compounds_lincs.smiles"
#
#
source $(dirname $CONDA_EXE)/../bin/activate cfde
#
###
# Lookup in CFChemDb compounds by SMILES:
ofile="$DATADIR/ReproTox_kg_compounds_lincs_cfchemdb.tsv"
python3 -m BioClients.cfde.cfchemdb.Client get_structure_by_smiles \
	--i ${smifile} \
	--o ${ofile} \
	-v -v \
	2>&1 |tee $DATADIR/ReproTox_kg_compounds_lincs_cfchemdb.log
###
#
conda deactivate
#
###
#
printf "Elapsed time: %ds\n" "$[$(date +%s) - ${T0}]"
#
