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
DATADIR="${cwd}/data"
DATAPATH="${cwd}/data/targetpages684/submission"
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
# Headers (blank tables) for all C2M2 TSVs, except file.tsv!
# https://osf.io/rdeks/
for f in $(ls ${cwd}/C2M2/*.tsv); do
	if [ $(basename $) = "file.tsv" ]; then
		continue
	fi
	printf "Copying C2M2 TSV header: %s\n" $(basename $f)
	cp $f $DATAPATH
done
#
#
cfde-submit run --help
#
cfde-submit login
#
cfde-submit run $DATAPATH \
	--dry-run \
	--dcc-id cfde_registry_dcc:idg \
	--output-dir $DATADIR/output \
	--verbose
#
