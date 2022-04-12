#!/bin/bash
###
DBNAME="loinc"
DBHOST="localhost"

cwd="$(pwd)"

DATADIR="${cwd}/data"

sql="\
SELECT
	loinc_num,
	component,
	class,
	definitiondescription,
	status,
	relatednames2,
	shortname,
	long_common_name,
	displayname,
	consumer_name
FROM
	loinc
WHERE
	class = 'CHEM'
ORDER BY component, loinc_num
"
#
psql -P pager=off -qAF $'\t' -h $DBHOST -d $DBNAME -c "${sql}" |sed '$d' \
	>$DATADIR/loinc_chem_names.tsv
#
# Split relatednames2 into separate rows.
