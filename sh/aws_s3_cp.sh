#!/bin/bash
###
# Needed since aws s3 cp does not allow wildcard specification of multiple files.
# Example use:
# aws_s3_cp.sh -p cfdeidg -d "s3://kmc-idg/unm/tcrd/" -f "$(ls tcrd_disease_DOID_*.json)"
###

AWS_PROFILE="cfdeidg"

help() {
	echo "syntax: $(basename $0) [parameters]"
	echo ""
	echo "  parameters (required):"
	echo "        -p PROFILE ....... AWS profile [$AWS_PROFILE]"
	echo "        -d DESTINATION ... AWS destination URI"
	echo "        -f FILES ......... local files, space separated"
	echo ""
}
#
if [ $# -eq 0 ]; then
	help
	exit 1
fi
#
### Parse args
DESTINATION=""
PROFILE=""
FILES=""
while getopts d:p:f: opt ; do
        case "$opt"
        in
        d)      DESTINATION=$OPTARG ;;
        p)      PROFILE=$OPTARG ;;
        f)      FILES=$OPTARG ;;
        \?)     help
		exit 1
                ;;
        esac
done
#
printf "PROFILE: ${PROFILE}\n"
printf "DESTINATION: ${DESTINATION}\n"
#
if [ ! $(echo "${DESTINATION}" |grep '^s3:') ]; then
	printf "DESTINATION invalid: \"${DESTINATION}\"\n"
	exit 1
fi
#
N=0
for f in $FILES ; do
	N=$[$N + 1]
done
#
i=0
for f in $FILES ; do
	i=$[$i + 1]
	cmd="aws --profile $PROFILE s3 cp ${f} ${DESTINATION}"
	printf "${i}/${N}. ${cmd}\n"
	${cmd}
done
