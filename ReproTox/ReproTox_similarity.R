#!/usr/bin/env Rscript
###
library(readr)
library(data.table)
library(plotly)
library(rcdk, quietly=T)
library(RPostgreSQL, quietly=T)

dbcon <- dbConnect(PostgreSQL(), host="unmtid-dbs.net", port=5442, dbname="cfchemdb", user="commoner", password="easement")

# For each compound NOT IN LINCS, what is the most similar compound IN LINCS?

sql <- "SELECT DISTINCT
	mols_a.id mol_id_a,
	mols_b.id mol_id_b,
	ROUND(tanimoto_sml(mols_a.fp, mols_b.fp)::NUMERIC, 3) tanimoto_rdfp,
	ROUND(tanimoto_sml(mols_a.ecfp, mols_b.ecfp)::NUMERIC, 3) tanimoto_ecfp
FROM
	(SELECT id,fp,ecfp FROM mols INNER JOIN reprotox ON reprotox.mol_id = mols.id) mols_a,
	(SELECT id,fp,ecfp FROM mols INNER JOIN reprotox ON reprotox.mol_id = mols.id) mols_b
WHERE
        mols_a.id NOT IN (SELECT mol_id FROM lincs WHERE mol_id IS NOT NULL)
        AND mols_b.id IN (SELECT mol_id FROM lincs WHERE mol_id IS NOT NULL)
ORDER BY
        mols_a.id, mols_b.id"

sims <- dbGetQuery(dbcon, sql)
setDT(sims)

sims[, tanimoto_ecfp_max := max(tanimoto_ecfp), by=mol_id_a]
sims <- sims[tanimoto_ecfp==tanimoto_ecfp_max]
sims[, tanimoto_ecfp_max := NULL]
setorder(sims, mol_id_a)
# Keep only first
sims[, `:=`(mol_id_b=first(mol_id_b), tanimoto_ecfp=first(tanimoto_ecfp)), by=mol_id_a]
sims <- unique(sims)

qs <- quantile(sims[, tanimoto_ecfp], c(0, .25, .75, seq(.8, 1, .01)))
writeLines(sprintf("Tanimoto %4s-ile: %9.1f", names(qs), qs))

plot_ly(type="histogram", x=sims[, tanimoto_ecfp])  %>%
  layout(title=sprintf("Tanimoto-ECFP similarity distribution<br>ReproTox-not-LINCS to most-similar LINCS compound"), margin=list(t=80, b=60, l=30),
         font=list(family="Arial", size=14), showlegend=F) %>%
  add_annotations(x=c(0.7), y=c(0.9),
                  xanchor="center", xref="paper", yref="paper", showarrow=F,
                  text=c(sprintf("N: %d", sims[, uniqueN(mol_id_a)])))
