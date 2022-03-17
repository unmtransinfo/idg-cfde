#!/bin/sh
#############################################################################
#
printf "Executing: %s\n" "$(basename $0)"
#
cwd=$(pwd)
#
NM_ROOT="$(cd $HOME/../app/nextmove; pwd)"
DICTDIR="${NM_ROOT}/leadmine-dictionaries-20181106/Dictionaries"
#
LIBDIR="$(cd $HOME/../app/lib; pwd)"
#
DATADIR="$cwd/data"
CFGDIR="${DATADIR}/config"
#
#############################################################################
# GeneAndProtein dictionaries and config files.
#
PREFIX="NM"
#
###
# CONFIG: Create LeadMine config file:
###
dicts="\
${DICTDIR}/CFDictGeneAndProtein.cfx
"
#
for f in $dicts ; do
	#
	entitytype=$(basename $f |perl -pe 's/^(.*)\.cfx$/$1/')
	printf "CFG: %s (%s)\n" $(basename $f) $entitytype
	DICTNAME="${PREFIX}_$(basename $f|sed -e 's/\.cfx$//')"
	#
	caseSens="false"
	minEntLen="5"
	spelCor="false"
	#spelCor="true"
	maxCorDist="1"
	minCorEntLen="5"
	#
	(cat <<__EOF__
[dictionary]
  location ${f}
  entityType ${entitytype}
  caseSensitive ${caseSens}
  minimumEntityLength ${minEntLen}
  useSpellingCorrection ${spelCor}
  maxCorrectionDistance  ${maxCorDist}
  minimumCorrectedEntityLength ${minCorEntLen}

__EOF__
) \
	>"$CFGDIR/${DICTNAME}.cfg"
done
#
###
#
nthreads="4"
#
# Cols:
# 1.	loinc_num,
# 2.	component,
# 3.	class,
# 4.	definitiondescription,
# 5.	status,
# 6.	relatednames2,
# 7.	shortname,
# 8.	long_common_name,
# 9.	displayname,
# 10.	consumer_name
#
#
echo "Gene+protein NER (descriptions)..."
#
for f in $(ls $CFGDIR/${PREFIX}_*.cfg) ; do
	#
	dictname=$(basename $f |perl -pe 's/^(.*)\.cfg$/$1/')
	printf "Leadmine: $(basename $f) (${dictname})\n"
	#
	for col in "2" "6" ; do
		java -jar $LIBDIR/unm_biocomp_nextmove-0.0.1-SNAPSHOT-jar-with-dependencies.jar \
			-config $f \
			-i ${DATADIR}/loinc_chem_names.tsv \
			-textcol $col -unquote -idcol 1 \
			-o ${DATADIR}/loinc_chem_names_${col}_${dictname}_leadmine.tsv \
			-v
	done
	#
done
#
