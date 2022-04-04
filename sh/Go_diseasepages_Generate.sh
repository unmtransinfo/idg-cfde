#!/bin/bash
# Create TCRD disease page files (with associations).
# Currently only handling DOIDs.
###
# Jan 2022?, New table: collection_disease
# New association: collection_describes_disease
# https://github.com/nih-cfde/published-documentation/wiki/TableInfo:-collection_disease.tsv
###

date

T0=$(date +%s)

#TCRD_VERSION="6110"
TCRD_VERSION="6124"

cwd=$(pwd)

DATADIR="${cwd}/data/diseasepages${TCRD_VERSION}"
if [ ! -f ${DATADIR} ]; then
	mkdir -p ${DATADIR}
fi
#
python3 -m BioClients.idg.tcrd.Client listDiseases \
	--o $DATADIR/tcrd_diseases.tsv
#
cat $DATADIR/tcrd_diseases.tsv |sed '1d' \
	|awk -F '\t' '{print $2}' |sort -u \
	|grep '^DOID' \
	>$DATADIR/tcrd_diseases.did
#
N=$(cat $DATADIR/tcrd_diseases.did |wc -l)
#
printf "N_diseases (DOID) = %d\n" "$N"
#
I=0
while [ $I -lt $N ]; do
	I=$[$I + 1]
	did=$(cat $DATADIR/tcrd_diseases.did |sed "${I}q;d")
	DID=$(printf "%06d" $(echo "${did}" |sed 's/^DOID://' |sed 's/^0*//'))
	FILENAME="tcrd_disease_DOID_${DID}.json"
	printf "${I}/${N}. DID=${did}; FILE=${FILENAME}\n"
	ofile=${DATADIR}/${FILENAME}
	python3 -m BioClients.idg.tcrd.Client getDiseaseAssociationsPage --ids "${did}" --o $ofile
done
#
printf "Elapsed: %ds\n" "$[$(date +%s) - $T0]"
date
#
