#!/bin/bash
# Create TCRD target page files, plus metadata TSV.
###

date

T0=$(date +%s)

TCRD_VERSION="684"

cwd=$(pwd)

DATADIR="${cwd}/data/targetpages${TCRD_VERSION}"
if [ ! -f ${DATADIR} ]; then
	mkdir -p ${DATADIR}
fi
metadatafile="${DATADIR}/tcrd_targetpages_c2m2.tsv"
printf "id_namespace\tlocal_id\tpersistent_id\tsize_in_bytes\tsha256\tmd5\tfilename\n" \
	>$metadatafile
#
python3 -m BioClients.idg.tcrd.Client listTargets \
	--o $DATADIR/tcrd_targets.tsv
#
cat $DATADIR/tcrd_targets.tsv |sed '1d' \
	|awk -F '\t' '{print $1}' |sort -nu \
	>$DATADIR/tcrd_targets.tid
#
N=$(cat $DATADIR/tcrd_targets.tid |wc -l)
#
printf "N_targets = %d\n" "$N"
#
ID_NAMESPACE="cfde_idg_tcrd"
#
if [ "$(which sha256sum)" ]; then
	SHA_EXE="sha256sum"
elif [ "$(which sha)" ]; then
	SHA_EXE="sha -a 256"
elif [ "$(which shasum)" ]; then
	SHA_EXE="shasum -a 256"
else
	echo "ERROR: Cannot find SHA_EXE."
	exit
fi
if [ "$(which md5sum)" ]; then
	MD5_EXE="md5sum"
elif [ "$(which md5)" ]; then
	MD5_EXE="md5"
else
	echo "ERROR: Cannot find MD5_EXE."
	exit
fi
#
I=0
while [ $I -lt $N ]; do
	I=$[$I + 1]
	tid=$(cat $DATADIR/tcrd_targets.tid |sed "${I}q;d")
	TID=$(printf "%05d" ${tid})
	FILENAME="tcrd_target_${TID}.json"
	printf "${I}. TID=${tid}; FILE=${FILENAME}\n"
	ofile=${DATADIR}/${FILENAME}
	python3 -m BioClients.idg.tcrd.Client getTargetPage --ids "${tid}" --o $ofile
	LOCAL_ID="TARGET_ID_${TID}"
	PERSISTENT_ID="${ID_NAMESPACE}.${TCRD_VERSION}.${LOCAL_ID}"
	SIZE_IN_BYTES=$(cat $ofile |wc -c)
	SHA256=$(cat $ofile |$SHA_EXE |sed 's/ .*$//')
	MD5=$(cat $ofile |$MD5_EXE |sed 's/ .*$//')
	printf "${ID_NAMESPACE}\t${LOCAL_ID}\t${PERSISTENT_ID}\t${SIZE_IN_BYTES}\t${SHA256}\t${MD5}\t${FILENAME}\n" \
		>>$metadatafile
done
#
printf "Elapsed: %ds\n" "$[$(date +%s) - $T0]"
date
#
