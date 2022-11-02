#! /usr/bin/env perl

use strict;

use URI::Escape;

$| = 1;

################################################################################
# SCRIPT PROVENANCE
################################################################################
# 
# Arthur Brady (University of Maryland Institute for Genome Sciences) wrote
# this script to generate JSON files describing basic iframe-includes,
# encoded in Chaise markdown, showing the UCSC Genome Browser's web UI genome
# track displays for specified genes (Ensembl IDs).
# 
# Chaise markdown guide: https://github.com/informatics-isi-edu/ermrestjs/blob/master/docs/user-docs/markdown-formatting.md
# 
# Creation date: 2022-06-29
# Lastmod date unless I forgot to change it: 2022-07-01
# 
################################################################################

################################################################################
# ARGUMENTS
################################################################################

my $idList = shift;

my $coordMap = shift;

my $widgetName = shift;

my $outDir = shift;

if ( $outDir eq '' ) {
	
	die("Usage: $0 <term ID list> <widget name> <output directory>\n");
}

if ( not -e $idList ) {
	
	die("FATAL: Can't open specified term ID list \"$idList\"; aborting.\n");
}

if ( not -e $coordMap ) {
	
	die("FATAL: Can't open specified gene coordinate map \"$coordMap\"; aborting.\n");
}

if ( not -d $outDir ) {
	
	system("mkdir -p $outDir");
}

################################################################################
# PARAMETERS
################################################################################

my $validationMatrix = 'data/validate/ensembl_genes.tsv';

################################################################################
# EXECUTION
################################################################################

################################################################################
# Preload valid Ensembl IDs.

my $validIDs = {};

open IN, "<$validationMatrix" or die("Can't open $validationMatrix for reading.\n");

my $header = <IN>;

while ( chomp( my $line = <IN> ) ) {
	
	my ( $termID, @theRest ) = split(/\t/, $line);

	$validIDs->{$termID} = 1;
}

close IN;

################################################################################
# Pre-load genome coordinates (chromosome/start/end) for Ensembl IDs.

my $coords = {};

open IN, "<$coordMap" or die("Can't open $coordMap for reading.\n");

$header = <IN>;

while ( chomp( my $line = <IN> ) ) {
	
	my ( $geneID, $chrID, $start, $end ) = split(/\t/, $line);

	$coords->{$geneID}->{$chrID}->{$start}->{$end} = 1;
}

close IN;

################################################################################
# Load target Ensembl IDs and ensure all are valid and have coordinate metadata.

my $targetIDs = {};

open IN, "<$idList" or die("Can't open $idList for reading.\n");

while ( chomp( my $id = <IN> ) ) {
	
	if ( not $validIDs->{$id} ) {
		
		die("FATAL: Target Ensembl gene ID \"$id\" not found in C2M2 reference list. Please check your sources and try again.\n");
	}

	if ( not exists( $coords->{$id} ) ) {
		
		die("FATAL: No chromosome coordinates loaded for Ensembl gene ID \"$id\"; aborting.\n");
	}

	$targetIDs->{$id} = 1;
}

close IN;

################################################################################
# Establish a custom browser URL for each target Ensembl ID.

my $targetURLs = {};

foreach my $termID ( keys %$targetIDs ) {
	
	# Each gene record has exactly one coordinate set in the coordinate map
	# file: the following is just artificially unrolling a fast data structure
	# and should not be taken to imply the existence of multiple versions of
	# any of the components (chr, start, end).

	foreach my $chr ( keys %{$coords->{$termID}} ) {
		
		foreach my $start ( keys %{$coords->{$termID}->{$chr}} ) {
			
			foreach my $end ( keys %{$coords->{$termID}->{$chr}->{$start}} ) {
				
				$targetURLs->{$termID} = "https://genome.ucsc.edu/cgi-bin/hgTracks?db=hg38&position=chr${chr}%3A${start}-${end}";
			}
		}
	}
}

################################################################################
# Save UCSC Genome Browser URLs for all successfully-processed Ensembl IDs.

foreach my $targetID ( sort { $a cmp $b } keys %$targetURLs ) {
	
	my $outFile = "$outDir/" . uri_escape("${widgetName}_${targetID}.json");

	open OUT, ">$outFile" or die("Can't open $outFile for writing.\n");

	print OUT '{"id": "' . $targetID . '", "resource_markdown": "::: iframe [**Context view (via UCSC Genome Browser):**](' . $targetURLs->{$targetID} . '){width=\"1200\" height=\"900\" style=\"border: 1px solid black;\" caption-style=\"font-size: 24px;\" caption-link=\"' . $targetURLs->{$targetID} . '\" caption-target=\"_blank\"} \n:::\n"}';

	close OUT;
	
	my $mdFile = "$outDir/" . uri_escape("${widgetName}_${targetID}.md");

	open OUT, ">$mdFile" or die("Can't open $mdFile for writing.\n");

	print OUT "::: iframe [**Context view (via UCSC Genome Browser):**]($targetURLs->{$targetID}){width=\"1200\" height=\"900\" style=\"border: 1px solid black;\" caption-style=\"font-size: 24px;\" caption-link=\"$targetURLs->{$targetID}\" caption-target=\"_blank\"} \n:::\n";

	close OUT;
}


