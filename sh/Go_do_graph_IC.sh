#!/bin/bash
###
# Information Content (IC) in an ontology graph refers to the specificity of 
# a node, measured by the fraction of a graph included by its subclasses.
# Thus a Maximally Informative Common Ancestor between two nodes is the 
# shared superclass, possibly among several, with greatest specificity, and
# smallest subclass-subgraph.
###
#
cwd=$(pwd)
#
DATADIR="$(cd $HOME/../data/DiseaseOntology/data; pwd)"
#
obofile="$DATADIR/doid.obo"
if [ ! -e "$obofile" ]; then
	wget -O $obofile https://github.com/DiseaseOntology/HumanDiseaseOntology/raw/main/src/ontology/releases/doid.obo
fi
#
#tags id,name,is_a
python3 -m BioClients.util.obo.App --i $obofile \
	|awk -F '\t' '{print $1 "\t" $2 "\t" $9}' \
	>$DATADIR/doid.tsv
#
rm -f ${DATADIR}/doid.graphml
touch ${DATADIR}/doid.graphml
#
cat <<__EOF__ >>$DATADIR/doid.graphml
<?xml version="1.0" encoding="UTF-8"?>
<graphml xmlns="http://graphml.graphdrawing.org/xmlns"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns
	http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">
  <key id="author" for="graph" attr.name="author" attr.type="string"/>
  <key id="name" for="graph" attr.name="name" attr.type="string"/>
  <key id="name" for="node" attr.name="name" attr.type="string"/>
  <key id="uri" for="node" attr.name="uri" attr.type="string"/>
  <key id="doid" for="node" attr.name="doid" attr.type="string"/>
  <key id="type" for="edge" attr.name="type" attr.type="string"/>
  <graph id="DO_CLASS_HIERARCHY" edgedefault="directed">
    <data key="name">Disease Ontology class hierarchy</data>
__EOF__
#
cat \
	$DATADIR/doid.tsv \
	|sed -e '1d' \
	|perl -pe 's/"\t"/\t/g' \
	|perl -pe 's/^"(.*)"(\s*)$/$1$2/' \
	|perl -ne '@_=split(/\t/,$_); print "\t<node id=\"$_[0]\"><data key=\"doid\">$_[0]</data><data key=\"name\">$_[1]</data></node>\n"' \
	>>$DATADIR/doid.graphml
#
cat \
	$DATADIR/doid.tsv \
	|sed -e '1d' \
	|perl -pe 's/"\t"/\t/g' \
	|perl -pe 's/^"(.*)"(\s*)$/$1$2/' \
	|perl -ne 's/[\n\r]//g; @f=split(/\t/,$_); @tgts=split(/;/,$f[2]); foreach $t (@tgts) { print "$f[0]\t$f[1]\t$t\n" }' \
	|perl -ne 's/[\n\r]//g; @_=split(/\t/,$_); print "\t<edge source=\"$_[2]\" target=\"$_[0]\"><data key=\"type\">subclass</data></edge>\n"' \
	>> $DATADIR/doid.graphml
#
cat <<__EOF__ >>$DATADIR/doid.graphml
  </graph>
</graphml>
__EOF__
#
###
#
python3 -m BioClients.util.igraph.App summary --i $DATADIR/doid.graphml
#
python3 -m BioClients.util.igraph.App rootnodes --i $DATADIR/doid.graphml -v -v
#
python3 -m BioClients.util.igraph.App shortest_path \
	--i $DATADIR/doid.graphml \
	--nidA "DOID:0014667" \
	--nidB "DOID:0050179"
#
###
#
python3 -m BioClients.util.igraph.App ic_computeIC -v -v \
	--i $DATADIR/doid.graphml \
	--o $DATADIR/doid_ic.graphml
#
###
# Step towards auto-slim algorithm.
python3 -m BioClients.util.igraph.App topnodes --depth 2 \
	--i $DATADIR/doid.graphml
#
