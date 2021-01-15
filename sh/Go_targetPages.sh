#!/bin/bash
# Create TCRD target page files, plus metadata in TSV.
###

cwd=$(pwd)

DATADIR="${cwd}/data/targetpages"

if [ ! -f ${DATADIR} ]; then
	mkdir -p ${DATADIR}
fi

metadatafile="${DATADIR}/tcrd_targetpages_metadata.tsv"
printf "id_namespace\tlocal_id\tpersistent_id\tsize_in_bytes\tsha256\tmd5\tfilename\n" \
	>$metadatafile

python3 -m BioClients.idg.tcrd.Client listTargets \
	--o $DATADIR/tcrd_targets.tsv

cat $DATADIR/tcrd_targets.tsv |sed '1d' \
	|awk -F '\t' '{print $1}' |sort -nu \
	>$DATADIR/tcrd_targets.tid
	
N=$(cat $DATADIR/tcrd_targets.tid |wc -l)

printf "N_targets = %d\n" "$N"

ID_NAMESPACE="http://nih-cfde.org/idg/tcrd"
TCRD_VERSION="670"

if [ "$(which sha256sum)" ]; then
	SHA_EXE="sha256sum"
elif [ "$(which sha)" ]; then
	SHA_EXE="sha -a 256"
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

I=0
while [ $I -lt $N ]; do
	I=$(($I + 1))
	tid=$(cat $DATADIR/tcrd_targets.tid |sed "${I}q;d")
	TID=$(printf "%05d" ${tid})
	FILENAME="$DATADIR/tcrd_target_${TID}.json"
	printf "${I}. TID=${tid}; FILE=${FILENAME}\n"
	python3 -m BioClients.idg.tcrd.Client getTargetPage --ids "${tid}" --o $FILENAME
	LOCAL_ID="TARGET_ID_${TID}"
	PERSISTENT_ID="${ID_NAMESPACE}/${TCRD_VERSION}/${LOCAL_ID}"
	SIZE_IN_BYTES=$(cat $FILENAME |wc -c)
	SHA256=$(cat $FILENAME |$SHA_EXE |sed 's/ .*$//')
	MD5=$(cat $FILENAME |$MD5_EXE |sed 's/ .*$//')
	printf "${ID_NAMESPACE}\t${LOCAL_ID}\t${PERSISTENT_ID}\t${SIZE_IN_BYTES}\t${SHA256}\t${MD5}\t${FILENAME}\n" \
		>>$metadatafile
done
