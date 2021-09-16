#!/bin/bash
###
# https://docs.nih-cfde.org/en/latest/cfde-submit/docs/
#
set -e
#set -x
#
#conda activate cfde
###
if [ ! $(which cfde-submit) ]; then
	echo "ERROR: cfde-submit not found. Maybe \"conda activate cfde\"?"
	conda env list
	exit
else
	printf "cfde-submit EXE: $(which cfde-submit)\n"
fi
#
TCRD_VERSION="6110"
#
cwd=$(pwd)
DATADIR="${cwd}/data/diseasepages${TCRD_VERSION}"
DATAPATH="${DATADIR}/submission"
#
if [ ! -e "$DATAPATH" ]; then
	mkdir -p $DATAPATH
fi
#
if [ ! "$DATAPATH/C2M2_datapackage.json" ]; then
	wget -O - 'https://osf.io/e5tc2/download' >$DATAPATH/C2M2_datapackage.json
fi
#
###
# Headers (blank tables) for all C2M2 TSVs!
# https://osf.io/rdeks/
i=0
for f in $(ls ${cwd}/C2M2/*.tsv); do
	i=$(($i + 1))
	printf "%d. Copying C2M2 TSV header: %s\n" "$i" "$(basename $f)"
	cp $f $DATAPATH
done
#
###
metadatafile="${DATADIR}/tcrd_diseasepages_c2m2.tsv"
printf "id_namespace\tlocal_id\tproject_id_namespace\tproject_local_id\tpersistent_id\tcreation_time\tsize_in_bytes\tuncompressed_size_in_bytes\tsha256\tmd5\tfilename\tfile_format\tdata_type\tassay_type\tmime_type\n" >$metadatafile
#
###
ID_NAMESPACE="cfde_idg_tcrd"
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
#
PROJECT_ID_NAMESPACE="cfde_idg_tcrd"
PROJECT_LOCAL_ID="idgtcrd"
CREATION_TIME=$(date +'%Y-%m-%d')
# http://edamontology.org/format_3464
FILE_FORMAT="format:3464"
DATA_TYPE=""
ASSAY_TYPE=""
MIME_TYPE="application/json"
#
I=0
for ofile in $(ls $DATADIR/tcrd_disease_*.json) ; do
	I=$[$I + 1]
	FILENAME=$(basename $ofile)
	DOID=$(echo "$ofile" |sed 's/^.*_\([0-9]*\)\.json$/\1/')
        printf "${I}. DOID:${DOID}; FILE=${FILENAME}\n"
	LOCAL_ID="DISEASE_DOID_${DOID}"
        PERSISTENT_ID="${ID_NAMESPACE}.${TCRD_VERSION}.${LOCAL_ID}"
        SIZE_IN_BYTES=$(cat $ofile |wc -c)
        UNCOMPRESSED_SIZE_IN_BYTES=${SIZE_IN_BYTES}
        SHA256=$(cat $ofile |$SHA_EXE |sed 's/ .*$//')
        MD5=$(cat $ofile |$MD5_EXE |sed 's/ .*$//')
        printf "${ID_NAMESPACE}\t${LOCAL_ID}\t${PROJECT_ID_NAMESPACE}\t${PROJECT_LOCAL_ID}\t${PERSISTENT_ID}\t${CREATION_TIME}\t${SIZE_IN_BYTES}\t${UNCOMPRESSED_SIZE_IN_BYTES}\t${SHA256}\t${MD5}\t${FILENAME}\t${FILE_FORMAT}\t${DATA_TYPE}\t${ASSAY_TYPE}\t${MIME_TYPE}\n" >>$metadatafile
done
#
###
#Overwrite file.tsv
cp $metadatafile ${DATAPATH}/file.tsv
###
# Required per:
# https://github.com/nih-cfde/published-documentation/wiki/C2M2-Table-Summary
printf "id\tabbreviation\tname\tdescription\n" >${DATAPATH}/id_namespace.tsv
printf "${PROJECT_ID_NAMESPACE}\tIDGTCRD\tIDG TCRD\tIDG Target Central Resource Database\n" >>${DATAPATH}/id_namespace.tsv
###
printf "contact_email\tcontact_name\tproject_id_namespace\tproject_local_id\tdcc_abbreviation\tdcc_name\tdcc_description\tdcc_url\n" >${DATAPATH}/primary_dcc_contact.tsv
printf "jjyang@salud.unm.edu\tJeremy Yang\t${PROJECT_ID_NAMESPACE}\t${PROJECT_LOCAL_ID}\tidg\tIDG\tIlluminating the Druggable Genome (IDG)\thttps://druggablegenome.net/\n" >>${DATAPATH}/primary_dcc_contact.tsv
###
printf "id_namespace\tlocal_id\tpersistent_id\tcreation_time\tabbreviation\tname\tdescription\n" >${DATAPATH}/project.tsv
printf "${PROJECT_ID_NAMESPACE}\t${PROJECT_LOCAL_ID}\tidg_diseasepages\t${CREATION_TIME}\ttgtpgs\tidg_diseasepages\tIDG
TCRD disease pages\n" >>${DATAPATH}/project.tsv
###
printf "id\tname\tdescription\n" >${DATAPATH}/file_format.tsv
printf "${FILE_FORMAT}\tJSON\tJavaScript Object Notation\n" >>${DATAPATH}/file_format.tsv
###
#cfde-submit run --help
cfde-submit login
cfde-submit run $DATAPATH \
	--dcc-id cfde_registry_dcc:idg \
	--output-dir $DATADIR/submission_output \
	--verbose
#
#	--dry-run \
#
cfde-submit status
#
