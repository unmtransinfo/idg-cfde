#!/usr/bin/env Rscript

library(readr)
library(data.table)
require(grid)
require(futile.logger)
library(VennDiagram)
library(rcdk)
#
smiparser <- get.smiles.parser()
#
cdksmi2mol <- function(smi) {
  parse.smiles(smi, kekulise=T)[[1]]
}
#
cdkmol2cansmi <- function(mol) {
  ifelse(!is.na(mol) & length(mol)>0, get.smiles(mol, smiles.flavors(c("Canonical", "Generic"))), NA) #Generic is non-isomeric
}
#
reprotox <- read_delim(paste0(Sys.getenv()["HOME"], "/../data/CFDE/ReproTox/LS_Mapping_std_can.smi"), "\t", col_names=c("CANSMI", "LS_ID"), show_col_types=F)
setDT(reprotox)
#reprotox[, cdk_mol := parse.smiles(CANSMI, kekulise=T, smiles.parser=smiparser)] #Works but to list not mol.
reprotox[["cdk_mol"]] <- lapply(reprotox[, CANSMI], cdksmi2mol)
reprotox[cdk_mol=="NULL", cdk_mol := NA]
message(sprintf("ReproTox SMILES missing or not successfully parsed: %d", reprotox[is.na(cdk_mol), .N]))
reprotox[["cdk_cansmi"]] <- unlist(lapply(reprotox[, cdk_mol], cdkmol2cansmi))
#
drugcentral <- read_delim(paste0(Sys.getenv()["HOME"], "/../data/CFDE/ReproTox/drugcentral_structures.tsv"), "\t", col_types=cols(.default=col_character()))
setDT(drugcentral)
dc_synonyms <- read_delim(paste0(Sys.getenv()["HOME"], "/../data/CFDE/ReproTox/drugcentral_synonyms.tsv"), "\t", col_types=cols(.default=col_character()))
setDT(dc_synonyms)
#dc_xrefs <- read_delim(paste0(Sys.getenv()["HOME"], "/../data/CFDE/ReproTox/drugcentral_xrefs.tsv"), "\t", col_types=cols(.default=col_character()))
#setDT(dc_xrefs)
#dc_xrefs[, .(uniqueN(struct_id), uniqueN(xref)), by="xref_type"]
#dc_pubchem <- dc_xrefs[xref_type=="PUBCHEM_CID"]
#dc_cids <- dc_pubchem[, unique(xref)]
#
#message(sprintf("ReproTox CIDs: %d; DrugCentral CIDs: %d; Intersection: %d (%.1f%%)", length(reprotox_cids), length(dc_cids), length(intersect(reprotox_cids, dc_cids)), 100*length(intersect(reprotox_cids, dc_cids)) / length(reprotox_cids)))
#
###
# Map by Cansmi:
#drugcentral[, cdk_mol := parse.smiles(smiles, kekulise=T, smiles.parser=smiparser)] #Works but to list not mol.
drugcentral[["cdk_mol"]] <- lapply(drugcentral[, smiles], cdksmi2mol)
drugcentral[cdk_mol=="NULL", cdk_mol := NA]
message(sprintf("DrugCentral SMILES missing or not successfully parsed: %d", drugcentral[is.na(cdk_mol), .N]))
drugcentral[["cdk_cansmi"]] <- unlist(lapply(drugcentral[, cdk_mol], cdkmol2cansmi))
#
rt_cansmis <- reprotox[!is.na(cdk_cansmi), unique(cdk_cansmi)]
dc_cansmis <- drugcentral[!is.na(cdk_cansmi), unique(cdk_cansmi)]
message(sprintf("ReproTox CANSMIs: %d; DrugCentral CANSMIs: %d; Intersection: %d (%.1f%%)", 
                length(rt_cansmis), length(dc_cansmis), length(intersect(rt_cansmis, dc_cansmis)), 
                100*length(intersect(rt_cansmis, dc_cansmis)) / length(rt_cansmis)))
#
###
# Map by drug name:
message(sprintf("ReproTox NAMEs: %d; IN-DrugCentral-SYNONYMS: %d (%.1f%%)", 
                length(rt_cansmis), length(dc_cansmis), length(intersect(rt_cansmis, dc_cansmis)), 
                100*length(intersect(rt_cansmis, dc_cansmis)) / length(rt_cansmis)))
#
bddcs <- read_delim(paste0(Sys.getenv()["HOME"], "/../data/CFDE/ReproTox/SI_S1_CompoundInfo.tsv"), "\t", col_types=cols(.default=col_character()))
setDT(bddcs)
bddcs[["cdk_mol"]] <- lapply(bddcs[, SMILES], cdksmi2mol)
bddcs[cdk_mol=="NULL", cdk_mol := NA]
message(sprintf("BDDCS SMILES missing or not successfully parsed: %d", bddcs[is.na(cdk_mol), .N]))
bddcs[["cdk_cansmi"]] <- unlist(lapply(bddcs[, cdk_mol], cdkmol2cansmi))
#
bddcs_bddcs <- read_delim(paste0(Sys.getenv()["HOME"], "/../data/CFDE/ReproTox/SI_S2_BDDCS2021.tsv"), "\t", col_types=cols(.default=col_character()))
setDT(bddcs_bddcs)
bddcs_bddcs <- bddcs_bddcs[, .(BDDCS.ID, BDDCS)]

bddcs <- merge(bddcs, bddcs_bddcs, by="BDDCS.ID", all=T, sort=F)
bddcs_cansmis <- bddcs[!is.na(cdk_cansmi), unique(cdk_cansmi)]
message(sprintf("ReproTox CANSMIs: %d; BDDCS CANSMIs: %d; Intersection: %d (%.1f%%)", 
                length(rt_cansmis), length(bddcs_cansmis), length(intersect(rt_cansmis, bddcs_cansmis)), 
                100*length(intersect(rt_cansmis, bddcs_cansmis)) / length(rt_cansmis)))
message(sprintf("BDDCS CANSMIs: %d; DrugCentral CANSMIs: %d; Intersection: %d (%.1f%%)", 
                length(bddcs_cansmis), length(dc_cansmis), length(intersect(bddcs_cansmis, dc_cansmis)), 
                100*length(intersect(bddcs_cansmis, dc_cansmis)) / length(bddcs_cansmis)))
#
display_venn <- function(x, ...) {
  grid.newpage()
  venn_object <- venn.diagram(x, filename=NULL, ...)
  grid.draw(venn_object)
}
#
X <- list(
  DrugCentral = dc_cansmis,
  ReproTox = rt_cansmis,
  BDDCS = bddcs_cansmis
)
display_venn(X, fill=c("pink", "#0073C2FF", "#EFC000FF"), main="RTECS-ReproTox, DrugCentral and BDDCS chemical datasets by CFDE-CDK-Cansmi")
#
###
# Annotate ReproTox with DrugCentral and BDDCS:
reprotox <- merge(reprotox, drugcentral[!is.na(cdk_cansmi), .(drugcentral_id=id, drugcentral_name=name, cdk_cansmi)], by="cdk_cansmi", all.x=T, all.y=F)
reprotox <- merge(reprotox, bddcs[!is.na(cdk_cansmi), .(BDDCS.ID, bddcs_name=Name, BDDCS, cdk_cansmi)], by="cdk_cansmi", all.x=T, all.y=F)
reprotox <- reprotox[, .(LS_ID, drugcentral_id, drugcentral_name, bddcs_id=BDDCS.ID, bddcs_name, BDDCS, cdk_cansmi, rdk_cansmi=CANSMI)]
reprotox <- reprotox[order(as.integer(sub("LS-", "", reprotox[["LS_ID"]])))]
#
message(sprintf("Unique LS_IDs: %d", reprotox[, uniqueN(LS_ID)]))
message(sprintf("Unique LS_IDs with DrugCentral IDs: %d (%.1f%%)", reprotox[!is.na(drugcentral_id), uniqueN(LS_ID)],
                100 * reprotox[!is.na(drugcentral_id), uniqueN(LS_ID)] / reprotox[, uniqueN(LS_ID)]))
message(sprintf("Unique LS_IDs with BDDCS IDs: %d (%.1f%%)", reprotox[!is.na(bddcs_id), uniqueN(LS_ID)],
                100 * reprotox[!is.na(bddcs_id), uniqueN(LS_ID)] / reprotox[, uniqueN(LS_ID)]))
message(sprintf("Unique LS_IDs with DrugCentral IDs AND BDDCS IDs: %d (%.1f%%)", reprotox[!is.na(drugcentral_id) & !is.na(bddcs_id), uniqueN(LS_ID)],
                100 * reprotox[!is.na(drugcentral_id) & !is.na(bddcs_id), uniqueN(LS_ID)] / reprotox[, uniqueN(LS_ID)]))
#
write_delim(reprotox, paste0(Sys.getenv()["HOME"], "/../data/CFDE/ReproTox/reprotox_ls_dc_bddcs.tsv"), delim="\t")
#
