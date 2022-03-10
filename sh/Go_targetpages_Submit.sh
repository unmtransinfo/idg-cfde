#!/bin/bash
###
# https://docs.nih-cfde.org/en/latest/cfde-submit/docs/
#
set -e
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
TCRD_VERSION="6124"
#
cwd=$(pwd)
DATADIR="$(cd $HOME/../data/CFDE; pwd)/data/targetpages${TCRD_VERSION}"
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
###
${cwd}/sh/Go_c2m2_DownloadSampleTables.sh $DATAPATH
#
CV_REF_DIR="$(cd $HOME/../data/CFDE; pwd)/data/CvRefDir"
${cwd}/sh/Go_c2m2_DownloadCVRefFiles.sh $CV_REF_DIR
#
# Auto-generate via prepare_C2M2_submission.py (https://osf.io/c67sp/download)
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
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-file.tsv
# https://osf.io/qjeb5/
echo "CREATE file.tsv (overwrite sample)."
printf "id_namespace\tlocal_id\tproject_id_namespace\tproject_local_id\tpersistent_id\tcreation_time\tsize_in_bytes\tuncompressed_size_in_bytes\tsha256\tmd5\tfilename\tfile_format\tdata_type\tassay_type\tmime_type\n" >${DATAPATH}/file.tsv
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-collection.tsv
# https://osf.io/3v2dt/
# Currently one file per collection this datapackage.
echo "CREATE collection.tsv (overwrite sample)."
printf "id_namespace\tlocal_id\tpersistent_id\tcreation_time\tabbreviation\tname\tdescription\n" >${DATAPATH}/collection.tsv
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-file_in_collection.tsv
# https://osf.io/84jfy/
# Currently one file per collection this datapackage.
echo "CREATE file_in_collection.tsv (overwrite sample)."
printf "file_id_namespace\tfile_local_id\tcollection_id_namespace\tcollection_local_id\n" >${DATAPATH}/file_in_collection.tsv
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-collection_defined_by_project.tsv
# https://osf.io/724sj/
echo "CREATE collection_defined_by_project.tsv (overwrite sample)."
printf "collection_id_namespace\tcollection_local_id\tproject_id_namespace\tproject_local_id\n" >${DATAPATH}/collection_defined_by_project.tsv
#
###
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-collection_gene.tsv
# EnsEMBL gene ID required.
echo "CREATE collection_gene.tsv (overwrite sample)."
printf "collection_id_namespace\tcollection_local_id\tgene\n" >${DATAPATH}/collection_gene.tsv
#
###
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
N=$(ls $DATADIR/tcrd_target_*.json |wc -l)
I=0
for ofile in $(ls $DATADIR/tcrd_target_*.json) ; do
	I=$[$I + 1]
	FILENAME=$(basename $ofile)
	TID=$(echo "$ofile" |sed 's/^.*_\([0-9]*\)\.json$/\1/')
        printf "${I}/${N}. TID=${TID}; FILE=${FILENAME}\n"
	FILE_LOCAL_ID="TARGET_ID_${TID}"
        FILE_PERSISTENT_ID="${FILE_ID_NAMESPACE}.${TCRD_VERSION}.${FILE_LOCAL_ID}"
        FILE_SIZE_IN_BYTES=$(cat $ofile |wc -c)
        FILE_UNCOMPRESSED_SIZE_IN_BYTES=${FILE_SIZE_IN_BYTES}
        SHA256=$(cat $ofile |$SHA_EXE |sed 's/ .*$//')
        MD5=$(cat $ofile |$MD5_EXE |sed 's/ .*$//')
	###
	# file.tsv
        printf "${FILE_ID_NAMESPACE}\t${FILE_LOCAL_ID}\t${PROJECT_ID_NAMESPACE}\t${PROJECT_LOCAL_ID}\t${FILE_PERSISTENT_ID}\t${CREATION_TIME}\t${FILE_SIZE_IN_BYTES}\t${FILE_UNCOMPRESSED_SIZE_IN_BYTES}\t${SHA256}\t${MD5}\t${FILENAME}\t${FILE_FORMAT}\t${DATA_TYPE}\t${ASSAY_TYPE}\t${MIME_TYPE}\n" >>${DATAPATH}/file.tsv
	###
	# collection.tsv
	COLLECTION_ABBREVIATION="${FILENAME}_collection"
	COLLECTION_NAME="TargetPage Collection: DOID:${DOID}"
	COLLECTION_DESCRIPTION="TargetPage Collection: ${GENE_NAME} (TID:${TID}; NCBI_GENE_ID:${GENE_ID}, FILE=${FILENAME})"
	COLLECTION_LOCAL_ID=$FILE_LOCAL_ID
        COLLECTION_PERSISTENT_ID="${COLLECTION_ID_NAMESPACE}.${TCRD_VERSION}.${COLLECTION_LOCAL_ID}"
        printf "${COLLECTION_ID_NAMESPACE}\t${COLLECTION_LOCAL_ID}\t${COLLECTION_PERSISTENT_ID}\t${CREATION_TIME}\t${COLLECTION_ABBREVIATION}\t${COLLECTION_NAME}\t${COLLECTION_DESCRIPTION}\n" >>${DATAPATH}/collection.tsv
	###
	# file_in_collection.tsv
        printf "${FILE_ID_NAMESPACE}\t${FILE_LOCAL_ID}\t${COLLECTION_ID_NAMESPACE}\t${COLLECTION_LOCAL_ID}\n" >>${DATAPATH}/file_in_collection.tsv
	###
	# collection_defined_by_project.tsv
        printf "${COLLECTION_ID_NAMESPACE}\t${COLLECTION_LOCAL_ID}\t${PROJECT_ID_NAMESPACE}\t${PROJECT_LOCAL_ID}\n" >>${DATAPATH}/collection_defined_by_project.tsv
	###
	# collection_gene.tsv
	ENSEMBL_GENE_ID=$(cat $ofile |grep ensemblGeneId |sed 's/^.*: "\(.*\)",/\1/')
        printf "${COLLECTION_ID_NAMESPACE}\t${COLLECTION_LOCAL_ID}\t${ENSEMBL_GENE_ID}\n" >>${DATAPATH}/collection_gene.tsv
	###
done
#
###
# Generate: gene.tsv, ...
# https://github.com/nih-cfde/published-documentation/wiki/C2M2-Table-Summary
# Generate derived ("Built by script") TSVs:
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
