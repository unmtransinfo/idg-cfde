#!/bin/bash
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

rm -f $DATAPATH/*

###
# Fix MSSM datapackage by updating to current schema.
# Use new datapackage.json
# Replace TSVs with one line only with current empty files.
# TSVs with 2+ lines may need to be manually fixed.

MSSM_DIR="${cwd}/data/MSSM/data_mssm"
MSSM_DIR_FIXED="${cwd}/data/MSSM/data_mssm_fixed"
if [ -e ${MSSM_DIR_FIXED} ]; then
	rm -f ${MSSM_DIR_FIXED}/*
else
	mkdir ${MSSM_DIR_FIXED}
fi
${cwd}/sh/Go_c2m2_DownloadSampleTables.sh ${MSSM_DIR_FIXED}
#
FILES_WITH_DATA=""
for f in $(ls $MSSM_DIR/*.tsv) ; do
	lc=$(cat $f |wc -l)
	if [ $lc -gt 1 ]; then
		printf "FILE HAS DATA; linecount: ${lc}; copied: ${f}\n"
		cp ${f} ${MSSM_DIR_FIXED}
		FILES_WITH_DATA="${FILES_WITH_DATA} ${f}"
	else
		printf "FILE HAS NO DATA; using updated template: %s/%s\n" ${MSSM_DIR_FIXED} $(basename ${f})
	fi
done

printf "Files with data:\n"
N_WITH_DATA=0
for f in ${FILES_WITH_DATA} ; do
	N_WITH_DATA=$[$N_WITH_DATA + 1]
	printf "\t${N_WITH_DATA}. ${f}\n"
done
printf "Files with data: ${N_WITH_DATA}\n"


###
${cwd}/python/datapackage_merge.py \
	${MSSM_DIR_FIXED} \
	${cwd}/data/diseasepages_6.13.4/submission \
	${cwd}/data/drugpages_2022-08-22/submission \
	${cwd}/data/targetpages_6.13.4/submission \
	${DATAPATH}
#
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
