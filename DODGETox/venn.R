#!/usr/bin/env Rscript
###
library(readr)
library(data.table)

set.seed(20190708)
genes <- paste("gene", 1:1000, sep="")
x <- list(
  A = sample(genes,300), 
  B = sample(genes,525), 
  C = sample(genes,440),
  D = sample(genes,350)
)

#library(ggvenn)
#ggvenn(x, fill_color = c("#0073C2FF", "#EFC000FF", "#868686FF", "#CD534CFF"), stroke_size = 0.5, set_name_size = 4)

#library(ggVennDiagram)
#ggVennDiagram(x, label_alpha = 0)

library(VennDiagram)

display_venn <- function(x, ...) {
  grid.newpage()
  venn_object <- venn.diagram(x, filename=NULL, ...)
  grid.draw(venn_object)
}

#display_venn(x, fill = c("#0073C2FF", "#EFC000FF", "#868686FF", "#CD534CFF"))


LS_Mapping <- read_delim("/disk2/data/CFDE/DODGETox/LS_Mapping_PubChem.tsv", "\t")
setDT(LS_Mapping)
LS_CIDs <- unique(LS_Mapping[!is.na(CID), CID])

SM_LINCS <- read_delim("/disk2/data/CFDE/DODGETox/SM_LINCS_10272021.tsv", "\t")
setDT(SM_LINCS)
SM_LINCS_CIDs <- unique(SM_LINCS[!is.na(SM_PubChem_CID), SM_PubChem_CID])

ReproTox_data_Blood <- read_delim("/disk2/data/CFDE/DODGETox/ReproTox_data-Blood_PubChem_cas2cid.tsv", "\t")
setDT(ReproTox_data_Blood)
ReproTox_data_Blood_CIDs <- unique(ReproTox_data_Blood[, CID])

ReproTox_data_Cardiovascular <- read_delim("/disk2/data/CFDE/DODGETox/ReproTox_data-Cardiovascular_PubChem_cas2cid.tsv", "\t")
setDT(ReproTox_data_Cardiovascular)
ReproTox_data_Cardiovascular_CIDs <- unique(ReproTox_data_Cardiovascular[, CID])

ReproTox_data_CNS <- read_delim("/disk2/data/CFDE/DODGETox/ReproTox_data-CNS_PubChem_cas2cid.tsv", "\t")
setDT(ReproTox_data_CNS)
ReproTox_data_CNS_CIDs <- unique(ReproTox_data_CNS[, CID])

display_venn(list(
  ReproTox_Blood = ReproTox_data_Blood_CIDs, 
  ReproTox_Cardiovascular = ReproTox_data_Cardiovascular_CIDs, 
  ReproTox_CNS = ReproTox_data_CNS_CIDs
  ), fill = c("#0073C2FF", "#EFC000FF", "#868686FF"))


display_venn(list(
  ReproTox_Blood = ReproTox_data_Blood_CIDs, 
  ReproTox_Cardiovascular = ReproTox_data_Cardiovascular_CIDs, 
  ReproTox_CNS = ReproTox_data_CNS_CIDs,
  LINCS = SM_LINCS_CIDs,
  LeadScope = LS_CIDs)
)
