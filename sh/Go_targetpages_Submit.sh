#!/bin/bash
###
# https://docs.nih-cfde.org/en/latest/cfde-submit/docs/
#
set -e
#
cwd=$(pwd)
#
T0=$(date +%s)
#
###
# First run Go_targetpages_Generate.sh and note DATADIR, needed
# as argument to this script.
#
if [ $# -ne 1 ]; then
	printf "ERROR: Syntax %s DATADIR\n" "$0"
	exit
else
	DATADIR="$1"
fi
#
DATADIR="$(cd $DATADIR; pwd)"
printf "DATADIR: ${DATADIR}\n"
#
DATAPATH="${DATADIR}/submission"
#
if [ ! -e "$DATAPATH" ]; then
	mkdir -p $DATAPATH
fi
#
###
# From https://docs.nih-cfde.org/en/latest/cfde-submit/docs/install/:
#       conda create --name cfde python
#       conda activate cfde
#       pip3 install --upgrade pip
#       pip3 install cfde-submit
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
# Headers (blank tables) for all C2M2 TSVs!
# Download files from https://osf.io/rdeks/.
# Download containing folder as zip: https://osf.io/rdeks/files/.
# Scriptable via https://github.com/osfclient/osfclient
# (pip install osfclient). Project is c8txv.
###
# Also download schema JSON: C2M2_datapackage.json
###
###
${cwd}/sh/Go_c2m2_DownloadSampleTables.sh $DATAPATH
#
CV_REF_DIR="$(cd $HOME/../data/CFDE; pwd)/data/CvRefDir"
${cwd}/sh/Go_c2m2_DownloadCVRefFiles.sh $CV_REF_DIR
CV_REF_ENSEMBL_FILE="${CV_REF_DIR}/ensembl_genes.tsv"
#
prepscript="${DATADIR}/prepare_C2M2_submission.py"
wget -O - 'https://osf.io/c67sp/download' >${prepscript}
#if [ -f ${prepscript} ]; then
#	printf "File exists, not downloaded: %s (may be custom version)\n" "${prepscript}"
#else
#	wget -O - 'https://osf.io/c67sp/download' >${prepscript}
#fi
perl -pi -e "s#^cvRefDir =.*\$#cvRefDir = '${CV_REF_DIR}'#" ${prepscript}
perl -pi -e "s#^submissionDraftDir =.*\$#submissionDraftDir = '${DATAPATH}'#" ${prepscript}
perl -pi -e "s#^outDir =.*\$#outDir = '${DATAPATH}'#"  ${prepscript}
chmod +x ${prepscript}
#
if [ "$(which sha256sum)" ]; then
	SHA_EXE="sha256sum"
elif [ "$(which sha)" ]; then
	SHA_EXE="sha -a 256"
elif [ "$(which shasum)" ]; then
	SHA_EXE="shasum -a 256"
else
	echo "ERROR: Cannot find SHA_EXE."
	exit
fi
if [ "$(which md5sum)" ]; then
	MD5_EXE="md5sum"
elif [ "$(which md5)" ]; then
	MD5_EXE="md5"
else
	echo "ERROR: Cannot find MD5_EXE."
	exit
fi
#
###
function Tsv2HeaderOnly {
	d=$(dirname $1)
	f=$(basename $1)
	echo "CREATE ${f} (overwrite with header only)."
	printf "${f} columns: %s\n" $(cat ${d}/${f} |head -1 |sed 's/\t/,/g')
	tmpfile=$(mktemp)
	cat ${1} |head -1 >${tmpfile}
	cp ${tmpfile} ${1}
	rm ${tmpfile}
}
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-file.tsv
# https://osf.io/qjeb5/
Tsv2HeaderOnly $DATAPATH/file.tsv
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-collection.tsv
# https://osf.io/3v2dt/
# Currently one file per collection this datapackage.
Tsv2HeaderOnly $DATAPATH/collection.tsv
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-file_in_collection.tsv
# https://osf.io/84jfy/
# Currently one file per collection this datapackage.
Tsv2HeaderOnly $DATAPATH/file_in_collection.tsv
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-collection_defined_by_project.tsv
# https://osf.io/724sj/
Tsv2HeaderOnly $DATAPATH/collection_defined_by_project.tsv
#
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-collection_gene.tsv
# EnsEMBL gene ID required.
Tsv2HeaderOnly $DATAPATH/collection_gene.tsv
#
###
PROJECT_ID_NAMESPACE="https://druggablegenome.net/cfde_idg_tcrd_targets"
PROJECT_LOCAL_ID="idg_tcrd_targets"
FILE_ID_NAMESPACE=$PROJECT_ID_NAMESPACE
COLLECTION_ID_NAMESPACE=$PROJECT_ID_NAMESPACE
#
FILE_AWS_HTTP_PREFIX="https://kmc-idg.s3.amazonaws.com/unm/tcrd"
#
CREATION_TIME=$(date +'%Y-%m-%d')
# http://edamontology.org/format_3464
FILE_FORMAT="format:3464"
DATA_TYPE=""
ASSAY_TYPE=""
MIME_TYPE="application/json"
#
N=$(ls $DATADIR/tcrd_target_*.json |wc -l)
N_NOT_FOUND="0"
I=0
for ofile in $(ls $DATADIR/tcrd_target_*.json) ; do
	I=$[$I + 1]
	FILENAME=$(basename $ofile)
	TID=$(echo "$ofile" |sed 's/^.*_\([0-9]*\)\.json$/\1/')
        printf "${I}/${N}. TID=${TID}; FILE=${FILENAME}\n"
	ENSEMBL_GENE_ID=$(cat $ofile |grep ensemblGeneId |sed 's/^.*: "\(.*\)".*$/\1/')
	# Check if ENSEMBL_GENE_ID in CV file?
	if [ !  "$(cat ${CV_REF_ENSEMBL_FILE} |grep "^${ENSEMBL_GENE_ID}\s")" ]; then
		printf "${I}/${N}. ERROR: ENSEMBL:${ENSEMBL_GENE_ID} not found in ${CV_REF_ENSEMBL_FILE}; skipping.\n"
		N_NOT_FOUND=$[$N_NOT_FOUND + 1]
		continue
	fi
        FILE_PERSISTENT_ID="${FILE_AWS_HTTP_PREFIX}/${FILENAME}"
	FILE_LOCAL_ID="TARGET_ID_${TID}"
        FILE_SIZE_IN_BYTES=$(cat $ofile |wc -c)
        FILE_UNCOMPRESSED_SIZE_IN_BYTES=${FILE_SIZE_IN_BYTES}
        FILE_SHA256=$(cat $ofile |$SHA_EXE |sed 's/ .*$//')
        FILE_MD5=$(cat $ofile |$MD5_EXE |sed 's/ .*$//')
	FILE_COMPRESSION_FORMAT=""
	FILE_ANALYSIS_TYPE=""
	FILE_BUNDLE_COLLECTION_ID_NAMESPACE=""
	FILE_BUNDLE_COLLECTION_LOCAL_ID=""
	FILE_DBGAP_STUDY_ID=""
	###
	# file.tsv
        printf "${FILE_ID_NAMESPACE}\t${FILE_LOCAL_ID}\t${PROJECT_ID_NAMESPACE}\t${PROJECT_LOCAL_ID}\t${FILE_PERSISTENT_ID}\t${CREATION_TIME}\t${FILE_SIZE_IN_BYTES}\t${FILE_UNCOMPRESSED_SIZE_IN_BYTES}\t${FILE_SHA256}\t${FILE_MD5}\t${FILENAME}\t${FILE_FORMAT}\t${FILE_COMPRESSION_FORMAT}\t${DATA_TYPE}\t${ASSAY_TYPE}\t${FILE_ANALYSIS_TYPE}\t${MIME_TYPE}\t${FILE_BUNDLE_COLLECTION_ID_NAMESPACE}\t${FILE_BUNDLE_COLLECTION_LOCAL_ID}\t${FILE_DBGAP_STUDY_ID}\n" >>${DATAPATH}/file.tsv
	###
	# collection.tsv
	COLLECTION_ABBREVIATION="$(echo ${FILENAME} |sed 's/\..*$//')_collection"
	COLLECTION_NAME="TargetPage_Collection_TID_${TID}"
	COLLECTION_DESCRIPTION="TargetPage Collection: ${GENE_NAME} (TID:${TID}; NCBI_GENE_ID:${GENE_ID}, FILE=${FILENAME})"
	COLLECTION_LOCAL_ID=$FILE_LOCAL_ID
        COLLECTION_PERSISTENT_ID="${COLLECTION_ID_NAMESPACE}.${TCRD_VERSION}.collection_${COLLECTION_LOCAL_ID}"
	COLLECTION_HAS_TIME_SERIES_DATA=""
        printf "${COLLECTION_ID_NAMESPACE}\t${COLLECTION_LOCAL_ID}\t${COLLECTION_PERSISTENT_ID}\t${CREATION_TIME}\t${COLLECTION_ABBREVIATION}\t${COLLECTION_NAME}\t${COLLECTION_DESCRIPTION}\t${COLLECTION_HAS_TIME_SERIES_DATA}\n" >>${DATAPATH}/collection.tsv
	###
	# file_in_collection.tsv
        printf "${FILE_ID_NAMESPACE}\t${FILE_LOCAL_ID}\t${COLLECTION_ID_NAMESPACE}\t${COLLECTION_LOCAL_ID}\n" >>${DATAPATH}/file_in_collection.tsv
	###
	# collection_defined_by_project.tsv
        printf "${COLLECTION_ID_NAMESPACE}\t${COLLECTION_LOCAL_ID}\t${PROJECT_ID_NAMESPACE}\t${PROJECT_LOCAL_ID}\n" >>${DATAPATH}/collection_defined_by_project.tsv
	###
	# collection_gene.tsv
        printf "${COLLECTION_ID_NAMESPACE}\t${COLLECTION_LOCAL_ID}\t${ENSEMBL_GENE_ID}\n" >>${DATAPATH}/collection_gene.tsv
	###
done
#
printf "ENSEMBL IDs NOT FOUND IN ${CV_REF_ENSEMBL_FILE}: ${N_NOT_FOUND}/${N}\n"
###
# Generate: gene.tsv, ...
# https://github.com/nih-cfde/published-documentation/wiki/C2M2-Table-Summary
# Generate derived ("Built by script") TSVs:
echo "RUNNING: ${prepscript}"
python3 ${prepscript}
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-id_namespace.tsv
# https://osf.io/6gahk/
Tsv2HeaderOnly $DATAPATH/id_namespace.tsv
printf "${PROJECT_ID_NAMESPACE}\tIDGTCRD\tIDG TCRD\tIDG Target Central Resource Database\n" >>${DATAPATH}/id_namespace.tsv
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-dcc.tsv
# https://osf.io/uvw9a/
Tsv2HeaderOnly $DATAPATH/dcc.tsv
DCC_ID="cfde_registry_dcc:idg"
printf "${DCC_ID}\tIlluminating the Druggable Genome (IDG)\tIDG\tThe goal of the Illuminating the Druggable Genome (IDG) program is to improve our understanding of the properties and functions of proteins that are currently unannotated within the three most commonly drug-targeted protein families: G-protein coupled receptors, ion channels, and protein kinases.\tjjyang@salud.unm.edu\tJeremy Yang\thttps://druggablegenome.net/\t${PROJECT_ID_NAMESPACE}\t${PROJECT_LOCAL_ID}\n" >>${DATAPATH}/dcc.tsv
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-project.tsv
# https://osf.io/ns4zf/
Tsv2HeaderOnly $DATAPATH/project.tsv
printf "${PROJECT_ID_NAMESPACE}\t${PROJECT_LOCAL_ID}\tidg_targetpages\t${CREATION_TIME}\ttgtpgs\tidg_targetpages\tIDG TCRD target pages\n" >>${DATAPATH}/project.tsv
###
###
# Login available via Google, ORCID, or Globus.
cfde-submit login
#
rm -rf $DATADIR/submission_output
#
DRY_RUN_ARG=""
#DRY_RUN_ARG="--dry-run"
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
