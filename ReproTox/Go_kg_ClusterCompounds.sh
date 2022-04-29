#!/bin/bash
###
# Cluster all compounds from KG.
###
#
T0=$(date +%s)
#
cwd=$(pwd)
DATADIR="${cwd}/data"
#
###
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
source $(dirname $CONDA_EXE)/../bin/activate rdktools
#
###
# --output_as_tsv: Output FPs as TSV with id and feature names as columns.
# This file for input to Scikit-learn agglomerative (Ward) hierarchical
# clustering. Linkage matrix (lmat) file for Plotly-sunburst and other 
# visualizations, etc.
ofile_fp="$DATADIR/ReproTox_kg_compounds_lincs_fp.tsv"
ofile_clusters="$DATADIR/ReproTox_kg_compounds_lincs_clusters.tsv"
ofile_clusters_lmat="$DATADIR/ReproTox_kg_compounds_lincs_clusters_lmat.tsv"
ofile_clusters_vis="$DATADIR/ReproTox_kg_compounds_lincs_clusters_dendrogram.png"
python3 -m rdktools.fp.App FingerprintMols \
	--i ${smifile} \
	--smilesColumn "canonical_smiles" --idColumn "id" \
	--output_as_tsv \
	--o ${ofile_fp}
#
python3 -m rdktools.util.sklearn.ClusterFingerprints cluster \
	--i ${ofile_fp} \
	--truncate_level 5 \
	--o ${ofile_clusters} \
	--o_lmat ${ofile_clusters_lmat} \
	--o_vis ${ofile_clusters_vis}
#	--display \
#
###
python3 ./cluster_sunburst.py
#
conda deactivate
#
###
#
printf "Elapsed time: %ds\n" "$[$(date +%s) - ${T0}]"
#
