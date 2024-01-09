#!/bin/bash
###
# Go_datapackage_Merge.sh
# Execute in this order:
#  - Go_datapackage_MSSM-Fix.sh
#  - Go_datapackage_Merge.sh
#  - Go_datapackage_Submit.sh
#
T0=$(date +%s)
TS=$(date +'%Y%m%d')

cwd=$(pwd)

###
# Fix MSSM datapackage by updating to current schema.
# Use new datapackage.json
# Replace TSVs with one line only with current empty files.
# TSVs with 2+ lines may need to be manually fixed.

MSSM_DIR="${cwd}/data/MSSM/data_mssm"
MSSM_DIR_FIXED="${cwd}/data/MSSM/data_mssm_fixed_${TS}"
printf "Un-fixed datapackage in: ${MSSM_DIR}\n"
#
if [ -e ${MSSM_DIR_FIXED} ]; then
	rm -f ${MSSM_DIR_FIXED}/*
else
	mkdir ${MSSM_DIR_FIXED}
fi
${cwd}/sh/Go_c2m2_DownloadSampleTables.sh ${MSSM_DIR_FIXED}
#
FILES_WITH_DATA=""
for f in $(ls $MSSM_DIR/*.tsv) ; do
	lc=$(cat $f |wc -l)
	if [ $lc -gt 1 ]; then
		printf "FILE HAS DATA; linecount: ${lc}; copied: ${f}\n"
		cp ${f} ${MSSM_DIR_FIXED}
		FILES_WITH_DATA="${FILES_WITH_DATA} ${f}"
	else
		printf "FILE HAS NO DATA; using updated template: %s/%s\n" ${MSSM_DIR_FIXED} $(basename ${f})
	fi
done

printf "Files with data:\n"
N_WITH_DATA=0
for f in ${FILES_WITH_DATA} ; do
	N_WITH_DATA=$[$N_WITH_DATA + 1]
	printf "\t${N_WITH_DATA}. ${f}\n"
done
printf "Files with data: ${N_WITH_DATA}\n"

###
printf "Fixed datapackage in: ${MSSM_DIR_FIXED}\n"
#
printf "Elapsed time: %ds\n" "$[$(date +%s) - ${T0}]"
#
