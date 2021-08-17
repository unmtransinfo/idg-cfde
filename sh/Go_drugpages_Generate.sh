#!/bin/bash
# Create DrugCentral drug page files.
###

date

T0=$(date +%s)

DC_VERSION="2020"

cwd=$(pwd)

DATADIR="${cwd}/data/drugpages${DC_VERSION}"
if [ ! -f ${DATADIR} ]; then
	mkdir -p ${DATADIR}
fi
#
python3 -m BioClients.drugcentral.Client list_structures \
	--o $DATADIR/drugcentral_structures.tsv
#
cat $DATADIR/drugcentral_structures.tsv |sed '1d' \
	|awk -F '\t' '{print $1}' |sort -nu \
	>$DATADIR/drugcentral_structures.struct_id
#
N=$(cat $DATADIR/drugcentral_structures.struct_id |wc -l)
#
printf "N_drugs = %d\n" "$N"
#
I=0
while [ $I -lt $N ]; do
	I=$[$I + 1]
	struct_id=$(cat $DATADIR/drugcentral_structures.struct_id |sed "${I}q;d")
	STRUCT_ID=$(printf "%05d" ${struct_id})
	FILENAME="drugcentral_drug_${STRUCT_ID}.json"
	printf "${I}. STRUCT_ID=${struct_id}; FILE=${FILENAME}\n"
	ofile=${DATADIR}/${FILENAME}
	python3 -m BioClients.drugcentral.Client get_drugpage --ids "${struct_id}" --o $ofile
done
#
printf "Elapsed: %ds\n" "$[$(date +%s) - $T0]"
date
#
