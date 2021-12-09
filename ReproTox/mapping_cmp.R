#!/usr/bin/env Rscript

library(readr)
library(data.table)

fname_um <- "LS_Mapping.smiles"
LS_UM <- read_delim(paste0(Sys.getenv()["HOME"], "/../data/CFDE/ReproTox/", fname_um), "\t", col_names = c("SMILES", "LS_ID"))
setDT(LS_UM)
message(sprintf("%s: rows: %d; SMILES: %d; unique(SMILES): %d; missing SMILES: %d; LS_ID: %d; unique(LS_ID): %d", fname_um, nrow(LS_UM),
	nrow(LS_UM[!is.na(SMILES)]),
	LS_UM[!is.na(SMILES), uniqueN(SMILES)],
	nrow(LS_UM[is.na(SMILES)]),
	nrow(LS_UM[!is.na(LS_ID)]),
	LS_UM[!is.na(LS_ID), uniqueN(LS_ID)]))

fname_ms <- "LS_mapping_MSSM.tsv"
LS_MS <- read_delim(paste0(Sys.getenv()["HOME"], "/../data/CFDE/ReproTox/", fname_ms), "\t", col_names = c("LS_ID", "TERM"))
setDT(LS_MS)
message(sprintf("%s: rows: %d; TERM: %d; unique(TERM): %d; LS_ID: %d; unique(LS_ID): %d", fname_ms, nrow(LS_MS),
	nrow(LS_MS[!is.na(TERM)]),
	LS_MS[!is.na(TERM), uniqueN(TERM)],
	nrow(LS_MS[!is.na(LS_ID)]),
	LS_MS[!is.na(LS_ID), uniqueN(LS_ID)]))

LS_IDs_UM <- unique(LS_UM[, LS_ID])
LS_IDs_MS <- unique(LS_MS[, LS_ID])

message(sprintf("IN-COMMON: (UM, MS): %d / %d", length(intersect(LS_IDs_MS, LS_IDs_UM)), length(union(LS_IDs_MS, LS_IDs_UM))))
message(sprintf("IN-UM and NOT-MS: %s", ifelse(length(setdiff(LS_IDs_UM, LS_IDs_MS))>0,  setdiff(LS_IDs_UM, LS_IDs_MS), "None")))
message(sprintf("IN-MS and NOT-UM: %s", ifelse(length(setdiff(LS_IDs_MS, LS_IDs_UM))>0,  setdiff(LS_IDs_MS, LS_IDs_UM), "None")))
#
