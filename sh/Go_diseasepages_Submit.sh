#!/bin/bash
###
# https://docs.nih-cfde.org/en/latest/cfde-submit/docs/
# https://github.com/nih-cfde/published-documentation/wiki (table descriptions)
# https://osf.io/rdeks/ (sample, empty table TSVs)
###
# New rule: Validation error in collection.tsv
# field "abbreviation" at position "5" does not conform to a constraint: constraint "pattern" is "^[a-zA-Z0-9_]+$"
###
set -e
#
cwd=$(pwd)
#
T0=$(date +%s)
#
###
# First run Go_diseasepages_Generate.sh and note DATADIR, needed
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
###
# From https://docs.nih-cfde.org/en/latest/cfde-submit/docs/install/:
#	conda create --name cfde python
#	conda activate cfde
#	pip install --upgrade pip
#	pip install --upgrade cfde-submit
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
${cwd}/sh/Go_c2m2_DownloadSampleTables.sh $DATAPATH
#
CV_REF_DIR="$(cd $HOME/../data/CFDE; pwd)/data/CvRefDir"
${cwd}/sh/Go_c2m2_DownloadCVRefFiles.sh $CV_REF_DIR
CV_REF_DOID_FILE="${CV_REF_DIR}/doid.version_2021-10-12.obo"
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
echo "CREATE file.tsv (overwrite sample with header only)."
Tsv2HeaderOnly $DATAPATH/file.tsv
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-collection.tsv
# https://osf.io/3v2dt/
# Currently one file per collection this datapackage.
Tsv2HeaderOnly $DATAPATH/collection.tsv
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-file_in_collection.tsv
# https://osf.io/84jfy/
Tsv2HeaderOnly $DATAPATH/file_in_collection.tsv
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-collection_defined_by_project.tsv
# https://osf.io/724sj/
Tsv2HeaderOnly $DATAPATH/collection_defined_by_project.tsv
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-collection_disease.tsv
# https://osf.io/r4uwa/
# Currently one collection per disease this datapackage.
Tsv2HeaderOnly $DATAPATH/collection_disease.tsv
#
PROJECT_ID_NAMESPACE="https://druggablegenome.net/cfde_idg_tcrd_diseases"
PROJECT_LOCAL_ID="idg_tcrd_diseases"
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
N=$(ls $DATADIR/tcrd_disease_*.json |wc -l)
I=0
for ofile in $(ls $DATADIR/tcrd_disease_*.json) ; do
	I=$[$I + 1]
	FILENAME=$(basename $ofile)
	DOID=$(echo "$ofile" |sed 's/^.*_0*\([1-9][0-9]*\)\.json$/\1/')
        printf "${I}/${N}. DOID:${DOID}; FILE=${FILENAME}\n"
	# Check if DOID in CV file?
	if [ !  "$(cat ${CV_REF_DOID_FILE} |grep "^id: DOID:${DOID}$")" ]; then
		if [ "$(cat ${CV_REF_DOID_FILE} |grep "^alt_id: DOID:${DOID}$")" ]; then
        		printf "${I}/${N}. ERROR: DOID:${DOID} alt_id in ${CV_REF_DOID_FILE}; skipping.\n"
		else
        		printf "${I}/${N}. ERROR: DOID:${DOID} not found in ${CV_REF_DOID_FILE}; skipping.\n"
		fi
		continue
	fi
        FILE_PERSISTENT_ID="${FILE_AWS_HTTP_PREFIX}/${FILENAME}"
	DISEASE_NAME=$(cat $ofile |grep diseaseName |sed 's/^.*: "\(.*\)",/\1/')
	FILE_LOCAL_ID="DISEASE_DOID_${DOID}"
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
	COLLECTION_NAME="DiseasePage Collection: DOID:${DOID}"
	COLLECTION_DESCRIPTION="DiseasePage Collection: ${DISEASE_NAME} (DOID:${DOID}, FILE=${FILENAME})"
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
	# collection_disease.tsv
        printf "${COLLECTION_ID_NAMESPACE}\t${COLLECTION_LOCAL_ID}\tDOID:${DOID}\n" >>${DATAPATH}/collection_disease.tsv
done
#
###
# Generate: disease.tsv, ...
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
printf "${PROJECT_ID_NAMESPACE}\t${PROJECT_LOCAL_ID}\tidg_diseasepages\t${CREATION_TIME}\ttgtpgs\tidg_diseasepages\tIDG TCRD disease pages\n" >>${DATAPATH}/project.tsv
###
# Login available via Google, ORCID, or Globus.
cfde-submit login
#
rm -rf $DATADIR/submission_output
#
#DRY_RUN_ARG=""
DRY_RUN_ARG="--dry-run"
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
