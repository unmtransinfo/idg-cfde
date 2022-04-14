#!/bin/bash
###
#
. $HOME/.neo4j.reprotox.sh
#
cwd=$(pwd)
DATADIR="${cwd}/data"
#
cql="\
MATCH (c:Chemical)
RETURN
c.name AS name,
c.curie AS curie,
c.URI as uri
"
#
cypher-shell \
	-a "bolt://${NEO4J_HOST}:${NEO4J_PORT}" \
	-u "${NEO4J_USERNAME}" \
	-p "${NEO4J_PASSWORD}" \
	--format "plain" \
	"${cql}" \
	|perl -pe 's/, /\t/g' |sed 's/"//g' \
	>${DATADIR}/ReproTox_kg_compounds.tsv
#
N=$[$(cat ${DATADIR}/ReproTox_kg_compounds.tsv |wc -l) - 1]
printf "Compound rows: ${N}\n"
#
#
LINCS_DIR=$(cd $HOME/../data/LINCS/data ; pwd)
small_molecules_file="${LINCS_DIR}/LINCS_small_molecules.tsv"
#
# Output is subset of small molecules file (keep header).
ofile="$DATADIR/ReproTox_kg_compounds_lincs.tsv"
#cat ${small_molecules_file} |head -1 >$ofile
printf "id\tpert_name\ttarget\tmoa\tcanonical_smiles\tinchi_key\tcompound_aliases\tsig_count\n" >$ofile
###
# Need escape: 'benzo(a)pyrene'
#
i="0"
n_not_found="0"
n_names_ambig="0"
while [ "${i}" -lt "${N}" ]; do
	i=$[$i + 1]
	name=$(cat ${DATADIR}/ReproTox_kg_compounds.tsv |awk -F '\t' '{print $1}' |sed '1d' |sed "${i}q;d")
	name_escaped=$(echo "${name}" |sed 's/(/\\(/g' |sed 's/)/\\)/g')
	row=$(cat $small_molecules_file |perl -ne "print if /\t${name_escaped}\t/")
	if [ $(echo "${row}" |wc -l) -gt 1 ]; then
		printf "Warning: multiple rows ($(echo "${row}" |wc -l)) for name ${name}; ($(echo "${row}" |awk -F '\t' '{print $1}' |perl -pe 's/\s/,/g')); keeping 1st only.\n"
		row=$(echo "${row}" |head -1)
		n_names_ambig=$[$n_names_ambig + 1]
	fi
	if [ "${row}" ]; then
		echo "${row}" >>$ofile
		printf "${i}/${N}. \"${name}\" (OK)\n"
	else
		printf "${i}/${N}. \"${name}\" (NOT FOUND)\n"
		n_not_found=$[$n_not_found + 1]
	fi
done
#
printf "FOUND: $[${N} - ${n_not_found}]/${N}; NOT FOUND: ${n_not_found}/${N}\n"
printf "Output TSV: ${ofile}\n"
ofile_smiles="$DATADIR/ReproTox_kg_compounds_lincs.smiles"
cat ${ofile} |awk -F '\t' '{print $5 "\t" $1 "\t" $2}' >${ofile_smiles}
printf "Output SMILES: ${ofile_smiles}\n"
printf "n_names_ambig: ${n_names_ambig}\n"
#
