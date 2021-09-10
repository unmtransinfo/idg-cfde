#!/bin/bash
###
#
cwd="$(pwd)"
#
python3 -m BioClients.util.pandas.Csv2Markdown -v -v \
	--skiprows 2 \
	--columns "Primary Table,Column name,Column description" \
	--title "TCRD Data Dictionary (Csv2Markdown, selected columns)" \
	--i ${cwd}/data_dictionary/tcrd_data_dictionary.tsv \
	--o ${cwd}/data_dictionary/tcrd_data_dictionary.md
#
