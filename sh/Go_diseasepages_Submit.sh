#!/bin/bash
###
# https://docs.nih-cfde.org/en/latest/cfde-submit/docs/
###
set -e
#set -x
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
if [ ! "$DATAPATH/C2M2_datapackage.json" ]; then
	wget -O - 'https://osf.io/e5tc2/download' >$DATAPATH/C2M2_datapackage.json
fi
#
###
# Headers (blank tables) for all C2M2 TSVs!
# Download files from https://osf.io/rdeks/.
# Download containing folder as zip: https://osf.io/rdeks/files/.
# Scriptable via https://github.com/osfclient/osfclient
# (pip install osfclient). Project is c8txv.
###
# This works:
wget -O - 'https://osf.io/hj9br/download' >$DATAPATH/anatomy.tsv
wget -O - 'https://osf.io/zhs7u/download' >$DATAPATH/assay_type.tsv
wget -O - 'https://osf.io/r5hp9/download' >$DATAPATH/biosample.tsv
wget -O - 'https://osf.io/phxzg/download' >$DATAPATH/biosample_disease.tsv
wget -O - 'https://osf.io/rscbg/download' >$DATAPATH/biosample_from_subject.tsv
wget -O - 'https://osf.io/2hx4u/download' >$DATAPATH/biosample_gene.tsv
wget -O - 'https://osf.io/4vybx/download' >$DATAPATH/biosample_in_collection.tsv
wget -O - 'https://osf.io/ea6j8/download' >$DATAPATH/biosample_substance.tsv
wget -O - 'https://osf.io/3v2dt/download' >$DATAPATH/collection.tsv
wget -O - 'https://osf.io/724sj/download' >$DATAPATH/collection_defined_by_project.tsv
wget -O - 'https://osf.io/fm8ca/download' >$DATAPATH/collection_in_collection.tsv
wget -O - 'https://osf.io/2qjmr/download' >$DATAPATH/compound.tsv
wget -O - 'https://osf.io/8qbsz/download' >$DATAPATH/data_type.tsv
wget -O - 'https://osf.io/uvw9a/download' >$DATAPATH/dcc.tsv
wget -O - 'https://osf.io/u4fsh/download' >$DATAPATH/disease.tsv
wget -O - 'https://osf.io/qjeb5/download' >$DATAPATH/file.tsv
wget -O - 'https://osf.io/bneza/download' >$DATAPATH/file_describes_biosample.tsv
wget -O - 'https://osf.io/6tmv8/download' >$DATAPATH/file_describes_collection.tsv
wget -O - 'https://osf.io/wf7vh/download' >$DATAPATH/file_describes_subject.tsv
wget -O - 'https://osf.io/9yzck/download' >$DATAPATH/file_format.tsv
wget -O - 'https://osf.io/84jfy/download' >$DATAPATH/file_in_collection.tsv
wget -O - 'https://osf.io/7t2pz/download' >$DATAPATH/gene.tsv
wget -O - 'https://osf.io/6gahk/download' >$DATAPATH/id_namespace.tsv
wget -O - 'https://osf.io/2k8a6/download' >$DATAPATH/ncbi_taxonomy.tsv
wget -O - 'https://osf.io/ns4zf/download' >$DATAPATH/project.tsv
wget -O - 'https://osf.io/pt2md/download' >$DATAPATH/project_in_project.tsv
wget -O - 'https://osf.io/ag9b5/download' >$DATAPATH/subject.tsv
wget -O - 'https://osf.io/27f9m/download' >$DATAPATH/subject_disease.tsv
wget -O - 'https://osf.io/w28fs/download' >$DATAPATH/subject_in_collection.tsv
wget -O - 'https://osf.io/d3evt/download' >$DATAPATH/subject_race.tsv
wget -O - 'https://osf.io/ucb82/download' >$DATAPATH/subject_role_taxonomy.tsv
wget -O - 'https://osf.io/v7b5q/download' >$DATAPATH/subject_substance.tsv
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
#
###
# Login available via Google, ORCID, or Globus.
cfde-submit login
#
#
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
