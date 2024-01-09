#!/bin/bash
###
# Go_datapackage_MSSM-Fix.sh
# Execute in this order:
#  - Go_datapackage_MSSM-Fix.sh
#  - Go_datapackage_Merge.sh
#  - Go_datapackage_Submit.sh
#
T0=$(date +%s)

cwd=$(pwd)

DATAPATH="${cwd}/data/merged-datapackage"

rm -f $DATAPATH/*

###
DATAPACKAGE_DIRS="\
${cwd}/data/MSSM/data_mssm_fixed_20240109 \
${cwd}/data/diseasepages_6.13.4/submission \
${cwd}/data/drugpages_2022-08-22/submission \
${cwd}/data/targetpages_6.13.4/submission \
"
###
printf "Input datapackages to be merged: ${DATAPACKAGE_DIRS}\n"
###
${cwd}/python/datapackage_merge.py \
	${DATAPACKAGE_DIRS} \
	${DATAPATH}
#
###
printf "Merged datapackage in: ${DATAPATH}\n"
#
printf "Elapsed time: %ds\n" "$[$(date +%s) - ${T0}]"
#
