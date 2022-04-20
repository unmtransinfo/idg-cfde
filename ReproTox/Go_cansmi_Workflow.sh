#!/bin/bash
###
#
cwd=$(pwd)
#
DATADIR="$(cd $HOME/../data/CFDE/ReproTox; pwd)"
#
###
source $(dirname $(which conda))/../bin/activate rdkit
python3 -m rdktools.standard.App standardize \
	--i ${DATADIR}/LS_Mapping.smiles --smilesColumn 0 --nameColumn 1 \
	--o ${DATADIR}/LS_Mapping_std.smi
# INFO:Mols in: 856; empty mols in: 75; mols out: 856; empty mols out: 75; errors: 3
###
python3 -m rdktools.util.Cansmi canonicalize \
	--i ${DATADIR}/LS_Mapping_std.smi \
	--o ${DATADIR}/LS_Mapping_std_can.smi
# INFO:Mols in: 856; mols out: 856; empty mols: 75
# INFO:Unique CANONICAL SMILES: 771
# INFO:Errors: 0
conda deactivate
###
python3 -m BioClients.pubchem.Client get_smi2cid \
	--i ${DATADIR}/LS_Mapping.smiles \
	--o ${DATADIR}/LS_Mapping_PubChem.tsv
# INFO:Input IDs: 856
# INFO:SMIs: 856; CIDs out: 743
#
cat ${DATADIR}/LS_Mapping_PubChem.tsv \
	|sed '1d' |awk -F '\t' '{print $1}' |grep -v '^$' |sort -u \
	>${DATADIR}/LS_Mapping_PubChem.cid
printf "LS CIDs: %d\n" $(cat ${DATADIR}/LS_Mapping_PubChem.cid |wc -l)
# LS CIDs: 737
###
cat ${DATADIR}/SM_LINCS_10272021.tsv \
	|sed '1d' |awk -F '\t' '{print $2}' |grep -v '^$' |sort -u \
	>${DATADIR}/SM_LINCS_10272021.cid
printf "LINCS CIDs: %d\n" $(cat ${DATADIR}/SM_LINCS_10272021.cid |wc -l)
# LINCS CIDs: 43827
###
source $(dirname $(which conda))/../bin/activate rdkit
python3 -m rdktools.standard.App standardize \
	--i ${DATADIR}/SM_LINCS_10272021.tsv \
	--header --smilesColumn 3 --nameColumn 0 \
	--o ${DATADIR}/SM_LINCS_10272021_std.smi
# INFO:Mols in: 44347; mols out: 44345; empty mols: 128
# INFO:Errors: 7
# [10:48:18] SMILES Parse Error: Failed parsing SMILES 'c1ccc2c(c1)[i+]c3ccccc23' for input: 'c1ccc2c(c1)[i+]c3ccccc23'
# ERROR:[N=2309] Failed to read mol.
# ERROR:[N=3069]: standardize failed: Explicit valence for atom # 2 N, 4, is greater than permitted
# ERROR:[N=41612]: standardize failed: Explicit valence for atom # 7 N, 4, is greater than permitted
# ERROR:[N=41630]: standardize failed: Explicit valence for atom # 11 N, 4, is greater than permitted
# ERROR:[N=44277]: standardize failed: Explicit valence for atom # 6 Cl, 2, is greater than permitted
# ERROR:[N=44278]: standardize failed: Explicit valence for atom # 6 Cl, 2, is greater than permitted
###
python3 -m rdktools.util.Cansmi canonicalize \
	--i ${DATADIR}/SM_LINCS_10272021_std.smi \
	--o ${DATADIR}/SM_LINCS_10272021_std_can.smi
# INFO:Mols in: 44345; mols out: 44345
# INFO:Empty mols: 128; non-empty mols: 44217
# INFO:Unique canonical SMILES: 23384
conda deactivate
#
###
(cd $DATADIR; ${cwd}/pdmerge.py)
# LS_Mapping_PubChem.tsv: rows: 743
# LS_Mapping_PubChem.tsv: unique CIDs: 737
# SM_LINCS_10272021.tsv: rows: 44346
# SM_LINCS_10272021.tsv: unique CIDs: 43827
# CIDS from Leadscope in LINCS: 243

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
