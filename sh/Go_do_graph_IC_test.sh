#!/bin/bash
#
###
cwd=$(pwd)
#
DATADIR="$(cd $HOME/../data/DiseaseOntology/data; pwd)"
#
doidAs="\
DOID:0050179 \
DOID:4411 \
DOID:1324 \
"
#
doidBs="\
DOID:0014667 \
DOID:1883 \
DOID:10283 \
"
#
for doidA in $doidAs ; do
	for doidB in $doidBs ; do
		if [ "$doidA" = "$doidB" ]; then
			continue
		fi
		echo "SIMILARITY($doidA , $doidB):"
		python3 -m BioClients.util.igraph.dag_ic findMICA \
			--i ${DATADIR}/doid_ic.graphml \
			--nidA "${doidA}"  --nidB "${doidB}" \
			-v -v
		echo ""
	done
done
#
