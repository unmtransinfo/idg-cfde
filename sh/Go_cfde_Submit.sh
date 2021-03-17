#!/bin/bash
###
# https://docs.nih-cfde.org/en/latest/cfde-submit/docs/
#
set -e
#
#conda activate cfde
#
cwd=$(pwd)
DATADIR="${cwd}/data"
DATAPATH="${cwd}/data/targetpages684"
#
if [ ! $(which cfde-submit) ]; then
	echo "ERROR: cfde-submit not found. Maybe \"conda activate cfde\"?"
	conda env list
	exit
else
	printf "cfde-submit EXE: $(which cfde-submit)\n"
fi
#
cfde-submit run --help
#
cfde-submit run $DATAPATH \
	--dry-run \
	--dcc-id cfde_registry_dcc:idg \
	--output-dir $DATADIR/output \
	--verbose
#
# 1st try error:
# [DEBUG] cfde_submit.main::run() No previous state found
# [DEBUG] cfde_submit.main::run() Determining DCC
# [DEBUG] cfde_submit.main::run() Initializing Flow
# [INFO] cfde_submit.client::check() Check PASSED, client is ready use flows.
# [DEBUG] cfde_submit.main::run() CfdeClient initialized, starting Flow
# Submit datapackage 'targetpages684' using cfde_registry_dcc:idg? (y/n)? > y
# [INFO] cfde_submit.client::check() Check PASSED, client is ready use flows.
# [DEBUG] cfde_submit.client::start_deriva_flow() Startup: Validating input
# [DEBUG] cfde_submit.bdbag_utils::get_bag() Checking for a Git repository
# [DEBUG] cfde_submit.bdbag_utils::get_bag() Git repo found, collecting metadata
# [DEBUG] cfde_submit.bdbag_utils::get_bag() Creating BDBag out of directory '/home/jjyang/src/idg-cfde/data/targetpages684'
# [DEBUG] cfde_submit.bdbag_utils::get_bag() Copying data to '/home/jjyang/src/idg-cfde/data/targetpages684_a037a3a437ae7a452796586e1278c25f5d5b4a90' before creating BDBag
# [DEBUG] cfde_submit.bdbag_utils::get_bag() BDBag created at '/home/jjyang/src/idg-cfde/data/targetpages684_a037a3a437ae7a452796586e1278c25f5d5b4a90'
# [DEBUG] cfde_submit.bdbag_utils::get_bag() Archiving BDBag at '/home/jjyang/src/idg-cfde/data/targetpages684_a037a3a437ae7a452796586e1278c25f5d5b4a90' using 'zip'
# [DEBUG] cfde_submit.bdbag_utils::get_bag() BDBag archived to file '/home/jjyang/src/idg-cfde/data/targetpages684_a037a3a437ae7a452796586e1278c25f5d5b4a90.zip'
# [DEBUG] cfde_submit.bdbag_utils::get_bag() Removing old directory '/home/jjyang/src/idg-cfde/data/targetpages684_a037a3a437ae7a452796586e1278c25f5d5b4a90'
# [DEBUG] cfde_submit.validation::validate_user_submission() Validating TableSchema in BDBag '/home/jjyang/src/idg-cfde/data/targetpages684_a037a3a437ae7a452796586e1278c25f5d5b4a90.zip'
# TableSchema invalid due to the following errors: 
# Multiple JSON files found in directory.
