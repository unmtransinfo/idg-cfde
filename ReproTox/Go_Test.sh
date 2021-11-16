#!/bin/bash
###
#
cwd=$(pwd)
#
DATADIR="$(cd $HOME/../data/CFDE/ReproTox; pwd)"
#
#
# Why are some CAS RNs mapped to so many PubChem CIDs?
###
function run_test {
	TERM=$1
	CASRN=$2
	printf "TERM=%s; CASRN=%s\n" "${TERM}" "${CASRN}"
	cat ${DATADIR}/ReproTox_data-${TERM}_PubChem_cas2cid.tsv \
		|grep "${CASRN}" |sed '1d' |awk -F '\t' '{print $3}' |sort -nu \
		>${DATADIR}/ReproTox_data-${TERM}-${CASRN}.cid
	python3 -m BioClients.pubchem.Client get_cid2smiles \
		--i ${DATADIR}/ReproTox_data-${TERM}-${CASRN}.cid \
		--o ${DATADIR}/ReproTox_data-${TERM}-${CASRN}_PubChem_smiles.tsv
	cat ${DATADIR}/ReproTox_data-${TERM}-${CASRN}_PubChem_smiles.tsv \
		|sed '1d' |awk -F '\t' '{print $3 "\t" $1}' \
		>${DATADIR}/ReproTox_data-${TERM}-${CASRN}_PubChem.smi
	python3 -m BioClients.pubchem.Client get_cid2properties \
		--i ${DATADIR}/ReproTox_data-${TERM}-${CASRN}.cid \
		--o ${DATADIR}/ReproTox_data-${TERM}-${CASRN}_PubChem_properties.tsv
	source $(dirname $(which conda))/../bin/activate rdkit
	python3 -m rdktools.depict.App pdf --nPerRow 2 --nPerCol 3 \
		--i ${DATADIR}/ReproTox_data-${TERM}-${CASRN}_PubChem.smi \
		--o ${DATADIR}/ReproTox_data-${TERM}-${CASRN}_PubChem.pdf
	conda deactivate
}
#
set -e
set -x
#
run_test "Blood" "32222-06-3"
#
run_test "CV" "50-14-6"
#
run_test "CNS" "13292-46-1"
#

