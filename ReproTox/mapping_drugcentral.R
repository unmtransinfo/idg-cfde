#!/usr/bin/env Rscript

library(readr)
library(data.table)
library(rcdk)
#
smiparser <- get.smiles.parser()
#
cdksmi2mol <- function(smi) {
  parse.smiles(smi, kekulise=T)[[1]]
}
#
cdkmol2cansmi <- function(mol) {
  ifelse(!is.na(mol) & length(mol)>0, get.smiles(mol, smiles.flavors("Canonical")), NA)
}
#
reprotox <- read_delim(paste0(Sys.getenv()["HOME"], "/../data/CFDE/ReproTox/LS_Mapping_UMiami_std_can.smi"), "\t", col_names=c("CANSMI", "LS_ID"))
setDT(reprotox)
#reprotox[, cdk_mol := parse.smiles(CANSMI, kekulise=T, smiles.parser=smiparser)] #Works but to list not mol.
reprotox[["cdk_mol"]] <- lapply(reprotox[, CANSMI], cdksmi2mol)
reprotox[cdk_mol=="NULL", cdk_mol := NA]
message(sprintf("Not successfully parsed: %d", reprotox[is.na(cdk_mol), .N]))
reprotox[, cdk_cansmi := lapply(reprotox[, cdk_mol], cdkmol2cansmi)]
#
drugcentral <- read_delim(paste0(Sys.getenv()["HOME"], "/../data/CFDE/ReproTox/drugcentral_structures.tsv"), "\t", col_types=cols(.default=col_character()))
setDT(drugcentral)
#dc_synonyms <- read_delim(paste0(Sys.getenv()["HOME"], "/../data/CFDE/ReproTox/drugcentral_synonyms.tsv"), "\t", col_types=cols(.default=col_character()))
#setDT(dc_synonyms)
#dc_xrefs <- read_delim(paste0(Sys.getenv()["HOME"], "/../data/CFDE/ReproTox/drugcentral_xrefs.tsv"), "\t", col_types=cols(.default=col_character()))
#setDT(dc_xrefs)
#dc_xrefs[, .(uniqueN(struct_id), uniqueN(xref)), by="xref_type"]
#dc_pubchem <- dc_xrefs[xref_type=="PUBCHEM_CID"]
#dc_cids <- dc_pubchem[, unique(xref)]
#
#message(sprintf("ReproTox CIDs: %d; DrugCentral CIDs: %d; Intersection: %d (%.1f%%)", length(reprotox_cids), length(dc_cids), length(intersect(reprotox_cids, dc_cids)), 100*length(intersect(reprotox_cids, dc_cids)) / length(reprotox_cids)))

#
#drugcentral[, cdk_mol := parse.smiles(smiles, kekulise=T, smiles.parser=smiparser)] #Works but to list not mol.
drugcentral[["cdk_mol"]] <- lapply(drugcentral[, smiles], cdksmi2mol)
drugcentral[cdk_mol=="NULL", cdk_mol := NA]
message(sprintf("Not successfully parsed: %d", drugcentral[is.na(cdk_mol), .N]))
drugcentral[, cdk_cansmi := lapply(drugcentral[, cdk_mol], cdkmol2cansmi)]
#
rt_cansmis <- reprotox[, unique(cdk_cansmi)]
dc_cansmis <- drugcentral[, unique(cdk_cansmi)]
message(sprintf("ReproTox CANSMIs: %d; DrugCentral CANSMIs: %d; Intersection: %d (%.1f%%)", 
                length(rt_cansmis), length(dc_cansmis), length(intersect(rt_cansmis, dc_cansmis)), 
                100*length(intersect(rt_cansmis, dc_cansmis)) / length(rt_cansmis)))
