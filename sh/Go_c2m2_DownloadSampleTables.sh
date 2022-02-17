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
# Download files from https://osf.io/rdeks/, folder as zip: https://osf.io/rdeks/files/.
# Project is c8txv.
###
# This works:
zipfile="$DATADIR/C2M2_SampleTables.zip"
wget -O - "https://files.osf.io/v1/resources/rdeks/providers/osfstorage/?zip=" >$zipfile
N=$(zipinfo -1 $zipfile |wc -l)
printf "C2M2 SampleTables (TSVs): ${N}\n"
(cd $DATADIR; rm *.tsv; unzip -o $zipfile)
#
###
wget -O - 'https://osf.io/vzgx9/download' >$DATADIR/C2M2_datapackage.json
printf "Downloaded: $DATADIR/C2M2_datapackage.json\n"
#
###
#
