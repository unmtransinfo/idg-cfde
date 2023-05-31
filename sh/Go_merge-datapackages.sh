#!/bin/bash
###

cwd=$(pwd)

ODIR="${cwd}/data/merged-datapackage

rm -f $ODIR/*

${cwd}/python/datapackage_merge.py \
	${cwd}/data/diseasepages_6.13.4/submission \
	${cwd}/data/drugpages_2022-08-22/submission \
	${cwd}/data/targetpages_6.13.4/submission \
	${ODIR}
#
