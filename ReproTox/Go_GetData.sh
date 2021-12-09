#!/bin/bash
###
# https://s3.amazonaws.com/lincs-dcic/sigcom-lincs-metadata/LINCS_small_molecules.tsv
###
cwd=$(pwd)
#
DATADIR="$(cd $HOME/../data/CFDE/ReproTox; pwd)"
#
###
python3 -m BioClients.pubchem.Client get_smi2cid \
	--i ${DATADIR}/LS_Mapping.smiles \
	--o ${DATADIR}/LS_Mapping_PubChem.tsv
# INFO:Input IDs: 856
# INFO:SMIs: 856; CIDs out: 743
#
cat ${DATADIR}/LS_Mapping_PubChem.tsv \
	|sed '1d' |awk -F '\t' '{print $1}' |grep -v '^$' |sort -u \
	|grep -v '^0$' \
	>${DATADIR}/LS_Mapping_PubChem.cid
printf "LS CIDs: %d\n" $(cat ${DATADIR}/LS_Mapping_PubChem.cid |wc -l)
# LS CIDs: 737
python3 -m BioClients.pubchem.Client get_cid2synonyms \
	--i ${DATADIR}/LS_Mapping_PubChem.cid \
	--o ${DATADIR}/LS_Mapping_PubChem_synonyms.tsv
#
###
cat ${DATADIR}/SM_LINCS_10272021.tsv \
	|sed '1d' |awk -F '\t' '{print $2}' |grep -v '^$' |sort -u \
	>${DATADIR}/SM_LINCS_10272021.cid
printf "LINCS CIDs: %d\n" $(cat ${DATADIR}/SM_LINCS_10272021.cid |wc -l)
# LINCS CIDs: 43827
#
###
for TERM in "Blood" "CV" "CNS"; do
	cat ${DATADIR}/ReproTox_data-${TERM}.tsv |sed '1d' |awk -F '\t' '{print $2}' |grep -v '^$' |sort -u >${DATADIR}/ReproTox_data-${TERM}.casrn
	python3 -m BioClients.pubchem.Client get_name2cid --i ${DATADIR}/ReproTox_data-${TERM}.casrn --o ${DATADIR}/ReproTox_data-${TERM}_PubChem_cas2cid.tsv
	n="$(cat ${DATADIR}/ReproTox_data-${TERM}.casrn |wc -l)"
	n_found="$(cat ${DATADIR}/ReproTox_data-${TERM}_PubChem_cas2cid.tsv |sed '1d' |awk -F '\t' '{print $1}' |sort -u |wc -l)"
	printf "ReproTox \"${TERM}\" CAS RNs found: ${n_found}/${n} ($((100 * ${n_found}/${n}))%%)\n"
done
#
###
# INFO:Input IDs: 125
# INFO:n_name: 125; n_sid: 9171; n_sid_unique: 9165; n_cid: 8965; n_cid_unique: 59
# ReproTox "Blood" CAS RNs found: 120/125 (96%)

###
# INFO:Input IDs: 600
# INFO:n_name: 600; n_sid: 36862; n_sid_unique: 36839; n_cid: 36151; n_cid_unique: 2512
# INFO:elapsed time: 03h:50m:35s
# ReproTox "CNS" CAS RNs found: 589/600 (98%)

###
# INFO:Input IDs: 272
# INFO:n_name: 272; n_sid: 18463; n_sid_unique: 18452; n_cid: 18165; n_cid_unique: 1095
# INFO:elapsed time: 01h:55m:01s
# ReproTox "CV" CAS RNs found: 266/272 (97%)
#
###
for TERM in "Blood" "CV" "CNS"; do
	cat ${DATADIR}/ReproTox_data-${TERM}_PubChem_cas2cid.tsv |sed '1d' |awk -F '\t' '{print $2}' |sort -u >${DATADIR}/ReproTox_data-${TERM}.sid
	printf "ReproTox_data-${TERM} SIDs: %d\n" $(cat ${DATADIR}/ReproTox_data-${TERM}.sid |wc -l)
	cat ${DATADIR}/ReproTox_data-${TERM}_PubChem_cas2cid.tsv |sed '1d' |awk -F '\t' '{print $3}' |sort -u >${DATADIR}/ReproTox_data-${TERM}.cid
	printf "ReproTox_data-${TERM} CIDs: %d\n" $(cat ${DATADIR}/ReproTox_data-${TERM}.cid |wc -l)
done
###
# CAS Common Chemistry API
for TERM in "Blood" "CV" "CNS"; do
	python3 -m BioClients.cas.Client get_rn2details \
		--i ${DATADIR}/ReproTox_data-${TERM}.casrn \
		--o ${DATADIR}/ReproTox_data-${TERM}_cas.tsv
done
###
# DrugCentral
python3 -m BioClients.drugcentral.Client list_structures --o ${DATADIR}/drugcentral_structures.tsv
python3 -m BioClients.drugcentral.Client list_synonyms --o ${DATADIR}/drugcentral_synonyms.tsv
#
