#!/usr/bin/env Rscript

library(readr)
library(data.table)
library(rcdk)
#
#
# mol_id_a mol_id_b tanimoto_rdfp tanimoto_ecfp
sims <- read_delim(paste0(Sys.getenv()["HOME"], "/../data/CFDE/ReproTox/ReproTox_simmatrix.tsv"), "\t")
setDT(sims)
#
xx <- cor(sims[,tanimoto_rdfp], sims[,tanimoto_ecfp], method="pearson", use="pairwise.complete.obs")
#
message(sprintf("RDKitFP_Tanimoto vs ECFP_FP_Tanimoto Pearson CORRELATION: %.2f", xx))
#
