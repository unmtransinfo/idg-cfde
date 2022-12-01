#!/bin/bash
# Create TCRD target page files.
###

date

T0=$(date +%s)

cwd=$(pwd)

TCRD_VERSION="$(python3 -m BioClients.idg.tcrd.Client info |sed '1d' |awk '{print $3}')"

printf "TCRD version: ${TCRD_VERSION}\n"

DATADIR="${cwd}/data/targetpages_${TCRD_VERSION}"
if [ ! -f ${DATADIR} ]; then
	mkdir -p ${DATADIR}
fi
#
python3 -m BioClients.idg.tcrd.Client listTargets \
	--o $DATADIR/tcrd_targets.tsv
#
cat $DATADIR/tcrd_targets.tsv |sed '1d' \
	|awk -F '\t' '{print $1}' |sort -nu \
	>$DATADIR/tcrd_targets.tid
#
N=$(cat $DATADIR/tcrd_targets.tid |wc -l)
#
printf "N_targets = %d\n" "$N"
#
I=0
while [ $I -lt $N ]; do
	I=$[$I + 1]
	tid=$(cat $DATADIR/tcrd_targets.tid |sed "${I}q;d")
	TID=$(printf "%05d" ${tid})
	FILENAME="tcrd_target_${TID}.json"
	printf "${I}/${N}. TID=${tid}; FILE=${FILENAME}\n"
	ofile=${DATADIR}/${FILENAME}
	python3 -m BioClients.idg.tcrd.Client getTargetPage --ids "${tid}" --o $ofile
done
#
printf "Elapsed: %ds\n" "$[$(date +%s) - $T0]"
date
#
