#!/bin/bash
###
# https://docs.nih-cfde.org/en/latest/cfde-submit/docs/
# https://github.com/nih-cfde/published-documentation/wiki (table descriptions)
# https://osf.io/rdeks/ (sample, empty table TSVs)
###
set -e
#
###
# From https://docs.nih-cfde.org/en/latest/cfde-submit/docs/install/:
#	conda create --name cfde python
#	conda activate cfde
#	pip3 install --upgrade pip
#	pip3 install cfde-submit
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
TCRD_VERSION="6124"
#
cwd=$(pwd)
#
DATADIR="$(cd $HOME/../data/CFDE/data/diseasepages${TCRD_VERSION}; pwd)"
DATAPATH="${DATADIR}/submission"
#
if [ ! -e "$DATAPATH" ]; then
	mkdir -p $DATAPATH
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
wget -O - 'https://osf.io/c67sp/download' \
	|perl -pe "s#^cvRefDir =.*\$#cvRefDir = '${CV_REF_DIR}'#" \
	|perl -pe "s#^submissionDraftDir =.*\$#submissionDraftDir = '${DATAPATH}'#" \
	|perl -pe "s#^outDir =.*\$#outDir = '${DATAPATH}'#" \
	>${DATADIR}/prepare_C2M2_submission.py
chmod +x ${DATADIR}/prepare_C2M2_submission.py
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
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-file.tsv
# https://osf.io/qjeb5/
echo "CREATE file.tsv (overwrite sample with header only)."
cat ${DATAPATH}/file.tsv |head -1 >${DATAPATH}/file.tsv
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-collection.tsv
# https://osf.io/3v2dt/
# Currently one file per collection this datapackage.
echo "CREATE collection.tsv (overwrite sample with header only)."
cat ${DATAPATH}/collection.tsv |head -1 >${DATAPATH}/collection.tsv
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-file_in_collection.tsv
# https://osf.io/84jfy/
# Currently one file per collection this datapackage.
echo "CREATE file_in_collection.tsv (overwrite sample with header only)."
cat ${DATAPATH}/file_in_collection.tsv |head -1 >${DATAPATH}/file_in_collection.tsv
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-collection_defined_by_project.tsv
# https://osf.io/724sj/
echo "CREATE collection_defined_by_project.tsv (overwrite sample with header only)."
cat ${DATAPATH}/collection_defined_by_project.tsv |head -1 >${DATAPATH}/collection_defined_by_project.tsv
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-collection_disease.tsv
# https://osf.io/r4uwa/
# Currently one collection per disease this datapackage.
echo "CREATE collection_disease.tsv (overwrite sample with header only)."
cat ${DATAPATH}/collection_disease.tsv |head -1 >${DATAPATH}/collection_disease.tsv
#
PROJECT_ID_NAMESPACE="cfde_idg_tcrd"
PROJECT_LOCAL_ID="idgtcrd"
FILE_ID_NAMESPACE=$PROJECT_ID_NAMESPACE
COLLECTION_ID_NAMESPACE=$PROJECT_ID_NAMESPACE
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
	DOID=$(echo "$ofile" |sed 's/^.*_\([0-9]*\)\.json$/\1/')
	# Check if DOID in CV file?
	if [ !  "$(cat ${CV_REF_DOID_FILE} |grep "^id: DOID:${DOID}$")" ]; then
		if [ "$(cat ${CV_REF_DOID_FILE} |grep "^alt_id: DOID:${DOID}$")" ]; then
        		printf "${I}/${N}. ERROR: DOID:${DOID} alt_id in ${CV_REF_DOID_FILE}; skipping.\n"
		else
        		printf "${I}/${N}. ERROR: DOID:${DOID} not found in ${CV_REF_DOID_FILE}; skipping.\n"
		fi
		continue
	fi
        printf "${I}/${N}. DOID:${DOID}; FILE=${FILENAME}\n"
	FILE_LOCAL_ID="DISEASE_DOID_${DOID}"
        FILE_PERSISTENT_ID="${FILE_ID_NAMESPACE}.${TCRD_VERSION}.file_${FILE_LOCAL_ID}"
        FILE_SIZE_IN_BYTES=$(cat $ofile |wc -c)
        FILE_UNCOMPRESSED_SIZE_IN_BYTES=${FILE_SIZE_IN_BYTES}
        FILE_SHA256=$(cat $ofile |$SHA_EXE |sed 's/ .*$//')
        FILE_MD5=$(cat $ofile |$MD5_EXE |sed 's/ .*$//')
	FILE_COMPRESSION_FORMAT=""
	FILE_ANALYSIS_TYPE=""
	FILE_BUNDLE_COLLECTION_ID_NAMESPACE=""
	FILE_BUNDLE_COLLECTION_LOCAL_ID=""
	###
	# file.tsv
        printf "${FILE_ID_NAMESPACE}\t${FILE_LOCAL_ID}\t${PROJECT_ID_NAMESPACE}\t${PROJECT_LOCAL_ID}\t${FILE_PERSISTENT_ID}\t${CREATION_TIME}\t${FILE_SIZE_IN_BYTES}\t${FILE_UNCOMPRESSED_SIZE_IN_BYTES}\t${FILE_SHA256}\t${FILE_MD5}\t${FILENAME}\t${FILE_FORMAT}\t${FILE_COMPRESSION_FORMAT}\t${DATA_TYPE}\t${ASSAY_TYPE}\t${FILE_ANALYSIS_TYPE}\t${MIME_TYPE}\t${FILE_BUNDLE_COLLECTION_ID_NAMESPACE}\t${FILE_BUNDLE_COLLECTION_LOCAL_ID}\n" >>${DATAPATH}/file.tsv
	###
	# collection.tsv
	DISEASE_NAME=$(cat $ofile |grep diseaseName |sed 's/^.*: "\(.*\)",/\1/')
	COLLECTION_ABBREVIATION="${FILENAME}_collection"
	COLLECTION_NAME="DiseasePage Collection: DOID:${DOID}"
	COLLECTION_DESCRIPTION="DiseasePage Collection: ${DISEASE_NAME} (DOID:${DOID}, FILE=${FILENAME})"
	COLLECTION_LOCAL_ID=$FILE_LOCAL_ID
        COLLECTION_PERSISTENT_ID="${COLLECTION_ID_NAMESPACE}.${TCRD_VERSION}.collection_${COLLECTION_LOCAL_ID}"
        printf "${COLLECTION_ID_NAMESPACE}\t${COLLECTION_LOCAL_ID}\t${COLLECTION_PERSISTENT_ID}\t${CREATION_TIME}\t${COLLECTION_ABBREVIATION}\t${COLLECTION_NAME}\t${COLLECTION_DESCRIPTION}\n" >>${DATAPATH}/collection.tsv
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
echo "RUNNING: ${DATADIR}/prepare_C2M2_submission.py"
${DATADIR}/prepare_C2M2_submission.py
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-id_namespace.tsv
# https://osf.io/6gahk/
echo "CREATE id_namespace.tsv (overwrite sample)."
printf "id\tabbreviation\tname\tdescription\n" >${DATAPATH}/id_namespace.tsv
printf "${PROJECT_ID_NAMESPACE}\tIDGTCRD\tIDG TCRD\tIDG Target Central Resource Database\n" >>${DATAPATH}/id_namespace.tsv
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-dcc.tsv
# https://osf.io/uvw9a/
echo "CREATE dcc.tsv (overwrite sample)"
# "contact_email\tcontact_name\tproject_id_namespace\tproject_local_id\tdcc_abbreviation\tdcc_name\tdcc_description\tdcc_url\n"
printf "id\tdcc_name\tdcc_abbreviation\tdcc_description\tcontact_email\tcontact_name\tdcc_url\tproject_id_namespace\tproject_local_id\n" >${DATAPATH}/dcc.tsv
printf "idg\tIlluminating the Druggable Genome (IDG)\tIDG\tThe goal of the Illuminating the Druggable Genome (IDG) program is to improve our understanding of the properties and functions of proteins that are currently unannotated within the three most commonly drug-targeted protein families: G-protein coupled receptors, ion channels, and protein kinases.\tjjyang@salud.unm.edu\tJeremy Yang\thttps://druggablegenome.net/\t${PROJECT_ID_NAMESPACE}\t${PROJECT_LOCAL_ID}\n" >>${DATAPATH}/dcc.tsv
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-project.tsv
# https://osf.io/ns4zf/
echo "CREATE project.tsv (overwrite sample)."
printf "id_namespace\tlocal_id\tpersistent_id\tcreation_time\tabbreviation\tname\tdescription\n" >${DATAPATH}/project.tsv
printf "${PROJECT_ID_NAMESPACE}\t${PROJECT_LOCAL_ID}\tidg_diseasepages\t${CREATION_TIME}\ttgtpgs\tidg_diseasepages\tIDG TCRD disease pages\n" >>${DATAPATH}/project.tsv
###
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-file_format.tsv
# https://osf.io/9yzck/
echo "CREATE file_format.tsv (overwrite sample)."
printf "id\tname\tdescription\n" >${DATAPATH}/file_format.tsv
printf "${FILE_FORMAT}\tJSON\tJavaScript Object Notation\n" >>${DATAPATH}/file_format.tsv
#
###
# Login available via Google, ORCID, or Globus.
cfde-submit login
#
rm -rf $DATADIR/submission_output
#
#cfde-submit run --help
cfde-submit run $DATAPATH \
	--dcc-id cfde_registry_dcc:idg \
	--output-dir $DATADIR/submission_output \
	--dry-run \
	--verbose
#
#	--dry-run \
#
cfde-submit status
#
conda deactivate
#
