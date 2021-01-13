#!/bin/bash
###

cwd=$(pwd)

DATADIR="${cwd}/data/targetpages"

if [ ! -f ${DATADIR} ]; then
	mkdir -p ${DATADIR}
fi

python3 -m BioClients.idg.tcrd.Client listTargets \
	--o $DATADIR/tcrd_targets.tsv

cat $DATADIR/tcrd_targets.tsv |sed '1d' \
	|awk -F '\t' '{print $1}' |sort -nu \
	>$DATADIR/tcrd_targets.tid
	
N=$(cat $DATADIR/tcrd_targets.tid |wc -l)

printf "N_targets = %d\n" "$N"

I=0
while [ $I -lt $N ]; do
	I=$(($I + 1))
	tid=$(cat $DATADIR/tcrd_targets.tid |sed "${I}q;d")
	python3 -m BioClients.idg.tcrd.Client getTargetPage --ids "${tid}" \
		--o $DATADIR/tcrd_target_$(printf "%05d" ${tid}).json
	printf "%d. TID=%s\n" "${I}" "${tid}"
done
