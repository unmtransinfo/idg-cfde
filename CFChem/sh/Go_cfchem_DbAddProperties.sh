#!/bin/bash
###
# Add molecular properties to all compounds in mols table.
###
#
T0=$(date +%s)
#
DBNAME="cfchemdb"
DBSCHEMA="public"
DBHOST="localhost"
#
TNAME="properties"
#
TMPDIR="$(cd $HOME/../data/CFDE/data/; pwd)/tmp/$(date +'%Y-%m-%d')"
printf "TMPDIR: ${TMPDIR}\n"
if [ ! -e $TMPDIR ]; then
	mkdir -p $TMPDIR
fi
#
###
# SMILES from molecules table:
psql -e -d $DBNAME -c "COPY (SELECT cansmi, id FROM mols ORDER BY id) TO STDOUT WITH (FORMAT CSV,HEADER,DELIMITER E'\t')" \
	>${TMPDIR}/${DBNAME}_mols.smi
#
###
if [ ! "$CONDA_EXE" ]; then
	CONDA_EXE=$(which conda)
fi
if [ ! "$CONDA_EXE" -o ! -e "$CONDA_EXE" ]; then
	echo "ERROR: conda not found."
	exit
fi
#
###
psql -e -d $DBNAME -c "DROP TABLE IF EXISTS $TNAME"
psql -e -d $DBNAME -c "CREATE TABLE $TNAME AS SELECT id FROM mols"
psql -e -d $DBNAME -c "ALTER TABLE $TNAME RENAME id TO mol_id"
#
#####################################################################
# Descriptors:
propfile=${TMPDIR}/${DBNAME}_mols_descriptors.smi
#
if [ ! -e "$propfile" ]; then
	source $(dirname $CONDA_EXE)/../bin/activate rdktools
	python3 -m rdktools.properties.App descriptors \
		--i ${TMPDIR}/${DBNAME}_mols.smi \
		--smilesColumn 0 --nameColumn 1 \
		--o ${propfile} \
		--iheader --oheader
	conda deactivate
	printf "Descriptors file generated: ${propfile}\n"
else
	printf "Descriptors file exists: ${propfile}\n"
fi
#
###
colnames=$(cat ${propfile} |head -1 |sed 's/\([a-z]\)\([A-Z]\)/\1_\2/g'|tr '[:upper:]' '[:lower:]')
printf "colnames: ${colnames}\n"
propnames=$(echo $colnames |sed 's/smiles\s//' |sed 's/name\s//')
N_props=$(echo $propnames |wc -w)
printf "propnames ($N_props): ${propnames}\n"
for propname in $propnames ; do
	psql -e -d $DBNAME -c "ALTER TABLE $TNAME ADD COLUMN $propname VARCHAR(32)"
done
#
N=$[$(cat ${propfile} |wc -l)-1]
i=0
while [ $i -lt $N ]; do
        i=$[$i + 1]
        line=$(cat ${propfile} |sed '1d' |sed "${i}q;d")
        mol_id=$(echo "$line" |awk -F '\t' '{print $2}')
	vals=$(echo $line |awk '{$1=$2=""; print $0}')
	vals=$(echo $vals |sed "s/\s/', '/g" |sed "s/^\(.*\)$/'\1'/")
	printf "${i}/${N}. mol_id=${mol_id} (${N_props} properties added)\n"
	psql -d $DBNAME -c "UPDATE $TNAME SET ($(echo $propnames |sed 's/\s/, /g')) = ROW(${vals}) WHERE mol_id = ${mol_id}"
done
#
#
for colname in $propnames ; do
	if [ "$(echo $colname |grep 'count')" -o "$(echo $colname |grep '^num_')" ]; then
		psql -e -d $DBNAME -c "ALTER TABLE $TNAME ALTER COLUMN $colname TYPE INT USING $colname::INTEGER"
		printf "Column ${TNAME}.${colname} altered to INT.\n"
	elif [ "$(echo $colname |grep 'mol_wt')" -o "$(echo $colname |grep 'partial_charge')" ]; then
		psql -e -d $DBNAME -c "ALTER TABLE $TNAME ALTER COLUMN $colname TYPE FLOAT USING $colname::FLOAT"
		printf "Column ${TNAME}.${colname} altered to FLOAT.\n"
	else
		printf "Column ${TNAME}.${colname} unaltered.\n"
	fi
done
#
#
#
#####################################################################
# Lipinski properties:
propfile=${TMPDIR}/${DBNAME}_mols_lipinski_properties.smi
#
if [ ! -e "$propfile" ]; then
	source $(dirname $CONDA_EXE)/../bin/activate rdktools
	python3 -m rdktools.properties.App lipinski \
		--i ${TMPDIR}/${DBNAME}_mols.smi \
		--smilesColumn 0 --nameColumn 1 \
		--o ${propfile} \
		--iheader --oheader
	conda deactivate
	printf "Properties file generated: ${propfile}\n"
else
	printf "Properties file exists: ${propfile}\n"
fi
#
###
colnames=$(cat ${propfile} |head -1 |sed 's/\([a-z]\)\([A-Z]\)/\1_\2/g'|tr '[:upper:]' '[:lower:]')
printf "colnames: ${colnames}\n"
propnames=$(echo $colnames |sed 's/smiles\s//' |sed 's/name\s//')
N_props=$(echo $propnames |wc -w)
printf "propnames ($N_props): ${propnames}\n"
for propname in $propnames ; do
	psql -e -d $DBNAME -c "ALTER TABLE $TNAME ADD COLUMN $propname VARCHAR(32)"
done
#
N=$[$(cat ${propfile} |wc -l)-1]
i=0
while [ $i -lt $N ]; do
        i=$[$i + 1]
        line=$(cat ${propfile} |sed '1d' |sed "${i}q;d")
        mol_id=$(echo "$line" |awk -F '\t' '{print $2}')
	vals=$(echo $line |awk '{$1=$2=""; print $0}')
	vals=$(echo $vals |sed "s/\s/', '/g" |sed "s/^\(.*\)$/'\1'/")
	printf "${i}/${N}. mol_id=${mol_id} (${N_props} properties added)\n"
	psql -d $DBNAME -c "UPDATE $TNAME SET ($(echo $propnames |sed 's/\s/, /g')) = ROW(${vals}) WHERE id = ${mol_id}"
done
#
#
for colname in $propnames ; do
	if [ "$(echo $colname |grep 'count')" -o "$(echo $colname |grep '^num_')" ]; then
		psql -e -d $DBNAME -c "ALTER TABLE $TNAME ALTER COLUMN $colname TYPE INT USING $colname::INTEGER"
		printf "Column ${TNAME}.${colname} altered to INT.\n"
	elif [ "$(echo $colname |grep 'fraction')" ]; then
		psql -e -d $DBNAME -c "ALTER TABLE $TNAME ALTER COLUMN $colname TYPE FLOAT USING $colname::FLOAT"
		printf "Column ${TNAME}.${colname} altered to FLOAT.\n"
	else
		printf "Column ${TNAME}.${colname} unaltered.\n"
	fi
done
#
#####################################################################
# LogP
propfile=${TMPDIR}/${DBNAME}_mols_logp.smi
if [ ! -e "$logpfile" ]; then
	source $(dirname $CONDA_EXE)/../bin/activate rdktools
	python3 -m rdktools.properties.App logp \
		--i ${TMPDIR}/${DBNAME}_mols.smi \
		--smilesColumn 0 --nameColumn 1 \
		--o ${propfile} \
		--iheader --oheader
	conda deactivate
	printf "LogP file generated: ${propfile}\n"
else
	printf "LogP file exists: ${propfile}\n"
fi
#
###
colnames=$(cat ${propfile} |head -1 |sed 's/\([a-z]\)\([A-Z]\)/\1_\2/g'|tr '[:upper:]' '[:lower:]')
printf "colnames: ${colnames}\n"
propnames=$(echo $colnames |sed 's/smiles\s//' |sed 's/name\s//')
N_props=$(echo $propnames |wc -w)
printf "propnames ($N_props): ${propnames}\n"
for propname in $propnames ; do
	psql -e -d $DBNAME -c "ALTER TABLE $TNAME ADD COLUMN $propname VARCHAR(32)"
done
#
N=$[$(cat ${propfile} |wc -l)-1]
i=0
while [ $i -lt $N ]; do
        i=$[$i + 1]
        line=$(cat ${propfile} |sed '1d' |sed "${i}q;d")
        mol_id=$(echo "$line" |awk -F '\t' '{print $2}')
	vals=$(echo $line |awk '{$1=$2=""; print $0}')
	vals=$(echo $vals |sed "s/\s/', '/g" |sed "s/^\(.*\)$/'\1'/")
	printf "${i}/${N}. mol_id=${mol_id} (${N_props} properties added)\n"
	psql -d $DBNAME -c "UPDATE $TNAME SET ($(echo $propnames |sed 's/\s/, /g')) = ROW(${vals}) WHERE id = ${mol_id}"
done
#
psql -e -d $DBNAME -c "ALTER TABLE $TNAME ALTER COLUMN wildman_crippen_logp TYPE FLOAT USING $colname::FLOAT"
#
#rm -rf $TMPDIR
#
printf "Elapsed time: %ds\n" "$[$(date +%s) - ${T0}]"
#
