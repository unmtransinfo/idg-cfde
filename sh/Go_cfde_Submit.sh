#!/bin/bash
###
# https://docs.nih-cfde.org/en/latest/cfde-submit/docs/
#
set -e
set -x
#
#conda activate cfde
#
cwd=$(pwd)
DATADIR="${cwd}/data/targetpages684"
DATAPATH="${DATADIR}/submission"
#
metadatafile="${DATADIR}/tcrd_targetpages_c2m2.tsv"
#
if [ ! -e "$DATAPATH" ]; then
	mkdir -p $DATAPATH
fi
#
if [ ! $(which cfde-submit) ]; then
	echo "ERROR: cfde-submit not found. Maybe \"conda activate cfde\"?"
	conda env list
	exit
else
	printf "cfde-submit EXE: $(which cfde-submit)\n"
fi
#
if [ ! "$DATAPATH/C2M2_datapackage.json" ]; then
	wget -O - 'https://osf.io/e5tc2/download' >$DATAPATH/C2M2_datapackage.json
fi
#
# Headers (blank tables) for all C2M2 TSVs!
# https://osf.io/rdeks/
i=0
for f in $(ls ${cwd}/C2M2/*.tsv); do
	i=$(($i + 1))
	printf "%d. Copying C2M2 TSV header: %s\n" "$i" "$(basename $f)"
	cp $f $DATAPATH
done
#
#
###
#Overwrite file.tsv
cp $metadatafile ${DATAPATH}/file.tsv
#
PROJECT_ID_NAMESPACE="idgtcrd"
PROJECT_LOCAL_ID="idgtcrd"
CREATION_TIME=$(date +'%Y-%m-%d')
###
# Required per:
# https://github.com/nih-cfde/published-documentation/wiki/C2M2-Table-Summary
printf "id\tabbreviation\tname\tdescription\n" >${DATAPATH}/id_namespace.tsv
printf "idgtcrd\tIDGTCRD\tIDG TCRD\tIDG Target Central Resource Database\n" >>${DATAPATH}/id_namespace.tsv
###
printf "contact_email\tcontact_name\tproject_id_namespace\tproject_local_id\tdcc_abbreviation\tdcc_name\tdcc_description\tdcc_url\n" >${DATAPATH}/primary_dcc_contact.tsv
printf "jjyang@salud.unm.edu\tJeremy Yang\t${PROJECT_ID_NAMESPACE}\t${PROJECT_LOCAL_ID}\tidg\tIDG\tIlluminating the Druggable Genome (IDG)\thttps://druggablegenome.net/\n" >>${DATAPATH}/primary_dcc_contact.tsv
###
printf "id_namespace\tlocal_id\tpersistent_id\tcreation_time\tabbreviation\tnamedescription\n" >${DATAPATH}/project.tsv
printf "idgtcrd\ttargetpages\tidg_targetpages\t${CREATION_TIME}\ttgtpgs\tIDG TCRD target pages\n" >>${DATAPATH}/project.tsv
###
cfde-submit run --help
#
cfde-submit login
#
cfde-submit run $DATAPATH \
	--dry-run \
	--dcc-id cfde_registry_dcc:idg \
	--output-dir $DATADIR/submission_output \
	--verbose
#
