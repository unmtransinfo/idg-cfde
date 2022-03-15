#!/bin/bash
###
# CV = controlled-vocabulary
# https://docs.nih-cfde.org/en/latest/cfde-submit/docs/
# https://github.com/nih-cfde/published-documentation/wiki/submission-prep-script
# https://github.com/nih-cfde/published-documentation/wiki/C2M2-Table-Summary
# https://osf.io/bq6k9/
###
set -e
#
###
#
if [ $# -ne 1 ]; then
	printf "ERROR: Syntax %s CV_REF_DIR\n" $(basename $0)
else
	CV_REF_DIR=$1
fi
#
printf "CV_REF_DIR: ${CV_REF_DIR}\n"
#
###
# Zipfile:5.3GB !!!
zipfile=${CV_REF_DIR}/external_CV_reference_files.zip
wget -O - 'https://files.osf.io/v1/resources/bq6k9/providers/osfstorage/611e9cf92dab24014f25ba63/?zip=' >$zipfile
N=$(zipinfo -1 $zipfile |wc -l)
printf "C2M2 External CV Reference Files: ${N}\n"
(cd $CV_REF_DIR; unzip -o $zipfile)
#
#
###
#