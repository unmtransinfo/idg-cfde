#!/bin/bash
###
# Go_datapackage_Submit.sh
# Execute in this order:
#  - Go_datapackage_MSSM-Fix.sh
#  - Go_datapackage_Merge.sh
#  - Go_datapackage_Submit.sh
###
#
if [ $# -ne 1 ]; then
	printf "ERROR: Syntax %s DRYRUN|SUBMIT\n" "$0"
	exit
else
	MODE="$1"
fi
if [ "$MODE" != "DRYRUN" -a "$MODE" != "SUBMIT" ]; then
	printf "ERROR: mode must be \"DRYRUN\" or \"SUBMIT\"\n"
	exit
fi
printf "MODE: ${MODE}\n"

T0=$(date +%s)

cwd=$(pwd)

DATADIR="${cwd}/data"

DATAPATH="${cwd}/data/merged-datapackage"

###
# Kludge! Deduplicate genes, compounds, file_formats.
${cwd}/python/deduplicate_gene_file.py ${DATAPATH}/gene.tsv >$DATADIR/gene.tsv
cp $DATADIR/gene.tsv ${DATAPATH}/
#
${cwd}/python/deduplicate_compound_file.py ${DATAPATH}/compound.tsv >$DATADIR/compound.tsv
cp $DATADIR/compound.tsv ${DATAPATH}/
#
python3 -m BioClients.util.pandas.App selectcols_deduplicate --i $DATAPATH/file_format.tsv --coltags "id" --o $DATADIR/file_format.tsv
cp $DATADIR/file_format.tsv $DATAPATH/
#
python3 -m BioClients.util.pandas.App selectcols_deduplicate --i $DATAPATH/ncbi_taxonomy.tsv --coltags "id" --o $DATADIR/ncbi_taxonomy.tsv
cp $DATADIR/ncbi_taxonomy.tsv $DATAPATH/
#
python3 -m BioClients.util.pandas.App selectcols_deduplicate --i $DATAPATH/dcc.tsv --coltags "id" --o $DATADIR/dcc.tsv
cp $DATADIR/dcc.tsv $DATAPATH/
###
# Kludge: create project_in_project.tsv
(cat <<__EOF__
parent_project_id_namespace	parent_project_local_id	child_project_id_namespace	child_project_local_id
https://www.druggablegenome.net/	IDG	https://www.druggablegenome.net/	Harmonizome
https://www.druggablegenome.net/	IDG	https://www.druggablegenome.net/	Drugmonizome
https://www.druggablegenome.net/	IDG	https://druggablegenome.net/cfde_idg_tcrd_diseases	idg_tcrd_diseases
https://www.druggablegenome.net/	IDG	https://druggablegenome.net/cfde_idg_drugcentral_drugs	idg_drugcentral_drugs
https://www.druggablegenome.net/	IDG	https://druggablegenome.net/cfde_idg_tcrd_targets	idg_tcrd_targets
__EOF__
	) >$DATAPATH/project_in_project.tsv

###
if [ ! "$CONDA_EXE" ]; then
	CONDA_EXE=$(which conda)
fi
if [ ! "$CONDA_EXE" -o ! -e "$CONDA_EXE" ]; then
	echo "ERROR: conda not found."
	exit
fi
source $(dirname $CONDA_EXE)/../bin/activate cfde
if [ ! $(which cfde-submit) ]; then
	echo "ERROR: cfde-submit not found."
	exit
else
	printf "cfde-submit EXE: $(which cfde-submit)\n"
fi
#
###
CV_REF_DIR="$(cd $HOME/../data/CFDE; pwd)/cfde-submit/CvRefDir"
###
prepscript="${DATADIR}/prepare_C2M2_submission.py"
wget -O - 'https://osf.io/c67sp/download' >${prepscript}
#
perl -pi -e "s#^cvRefDir =.*\$#cvRefDir = '${CV_REF_DIR}'#" ${prepscript}
perl -pi -e "s#^submissionDraftDir =.*\$#submissionDraftDir = '${DATAPATH}'#" ${prepscript}
perl -pi -e "s#^outDir =.*\$#outDir = '${DATAPATH}'#"  ${prepscript}
chmod +x ${prepscript}

###
# Login available via Google, ORCID, or Globus.
cfde-submit login
#
rm -rf $DATADIR/submission_output
#
printf "MODE: ${MODE}\n"
if [ "$MODE" = "SUBMIT" ]; then
	DRY_RUN_ARG=""
else
	DRY_RUN_ARG="--dry-run"
fi
#
#cfde-submit run --help
cfde-submit run $DATAPATH $DRY_RUN_ARG \
	--dcc-id cfde_registry_dcc:idg \
	--output-dir $DATADIR/submission_output \
	--verbose
#
while [ 1 ]; do
	if [ "$DRY_RUN_ARG" ]; then
		break
	fi
	x=$(cfde-submit status)
	echo ${x}
	if [ ! "$(echo ${x} |grep 'still in progress')" ]; then
		break
	fi
	sleep 10
done
#
conda deactivate
#
printf "Elapsed time: %ds\n" "$[$(date +%s) - ${T0}]"
#
