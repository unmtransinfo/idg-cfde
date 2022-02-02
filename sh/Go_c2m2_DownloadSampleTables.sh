#!/bin/bash
###
# https://docs.nih-cfde.org/en/latest/cfde-submit/docs/
###
set -e
#
###
#
if [ $# -ne 1 ]; then
	printf "ERROR: Syntax %s DATADIR\n" $(basename $0)
else
	DATADIR=$1
fi
#
printf "DATADIR: ${DATADIR}\n"
###
# Headers (blank tables) for all C2M2 TSVs!
# Download files from https://osf.io/rdeks/.
# Download containing folder as zip: https://osf.io/rdeks/files/.
# Scriptable via https://github.com/osfclient/osfclient
# (pip install osfclient). Project is c8txv.
###
# This works:
flistfile="$(dirname $0)/c2m2_SampleTables.tsv"
N=$(cat $flistfile |wc -l)
printf "C2M2 SampleTable TSVs: ${N}\n"
#
I=0
n_exist=0
n_download=0
while [ "${I}" -lt "${N}" ]; do
	I=$[$I + 1]
	line=$(cat $flistfile |sed "${I}q;d")
	url=$(echo "$line" |awk -F '\t' '{print $1}')
	fname=$(echo "$line" |awk -F '\t' '{print $2}')
	printf "${I}/${N}. URL=${url}; FILE=${fname}\n"
	if [ -e $DATADIR/${fname} ]; then
		printf "File exists: $DATADIR/${fname}\n"
		n_exist=$[$n_exist + 1]
	else
		wget -O - ${url} >$DATADIR/${fname}
		n_download=$[$n_download + 1]
	fi
done
printf "Downloaded: ${n_download}/${N}; exists: ${n_exist}/${N}\n"
#
###
if [ -e "$DATADIR/C2M2_datapackage.json" ]; then
	printf "Exists: $DATADIR/C2M2_datapackage.json\n"
else
	#wget -O - 'https://osf.io/e5tc2/download' >$DATADIR/C2M2_datapackage.json
	wget -O - 'https://osf.io/vzgx9/download' >$DATADIR/C2M2_datapackage.json
	printf "Downloaded: $DATADIR/C2M2_datapackage.json\n"
fi
#
###
#
