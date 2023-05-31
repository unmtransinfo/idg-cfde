#!/bin/bash
###
# https://docs.nih-cfde.org/en/latest/cfde-submit/docs/
###
set -e
#
###
function Tsv2HeaderOnly {
	d=$(dirname $1)
	f=$(basename $1)
	echo "CREATE ${f} (overwrite with header only)."
	printf "${f} columns: %s\n" $(cat ${d}/${f} |head -1 |sed 's/\t/,/g')
	tmpfile=$(mktemp)
	cat ${1} |head -1 >${tmpfile}
	cp ${tmpfile} ${1}
	rm ${tmpfile}
}
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
(cd $DATADIR; rm -f *.tsv; unzip -o $zipfile)
rm $zipfile
#
# Delete the files to be "Built by script."
# https://github.com/nih-cfde/published-documentation/wiki/C2M2-Table-Summary
###
# Maybe these are not "Built by script." (document typos?)
# phenotype_disease.tsv
# phenotype_gene.tsv
###
BUILT_BY_SCRIPT_TSVS="\
anatomy.tsv
analysis_type.tsv
assay_type.tsv
compound.tsv
data_type.tsv
disease.tsv
file_format.tsv
gene.tsv
ncbi_taxonomy.tsv
phenotype.tsv
substance.tsv
"
for f in $BUILT_BY_SCRIPT_TSVS ; do
	printf "Removing BUILT_BY_SCRIPT_TSV: ${f}\n"
	rm $DATADIR/$f
done
###
# Header-only TSVs (to be overwritten as needed):
for f in $(ls $DATADIR/*.tsv) ; do
	Tsv2HeaderOnly ${f}
done
###
schema_url="https://osf.io/vzgx9/download"
wget -O - $schema_url >$DATADIR/datapackage.json
printf "Downloaded: $DATADIR/datapackage.json\n"
#
###
#
