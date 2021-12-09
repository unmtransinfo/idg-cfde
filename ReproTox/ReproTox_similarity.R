library(readr)
library(data.table)
library(plotly)
library(rcdk, quietly=T)
library(RPostgreSQL, quietly=T)

dbcon <- dbConnect(PostgreSQL(), host="unmtid-dbs.net", port=5442, dbname="cfchemdb", user="commoner", password="easement")

reprotox <- dbGetQuery(dbcon, "SELECT * FROM reprotox")
setDT(reprotox)
lincs <- dbGetQuery(dbcon, "SELECT * FROM lincs")
setDT(lincs)

sql <- "SELECT
  reprotox.mol_id,
  reprotox.ls_id,
  reprotox.pubchem_cid,
  reprotox.cansmi,
  lincs.id lcs_id,
  lincs.pert_name
FROM
  reprotox
  JOIN lincs ON lincs.mol_id = reprotox.mol_id
"
reprotox_lincs <- dbGetQuery(dbcon, sql)
setDT(reprotox_lincs)
message(sprintf("ReproTox_LINCS: unique CANSMIs: %d; LS_ID: %d; LCS_ID: %d", reprotox_lincs[, uniqueN(cansmi)], reprotox_lincs[, uniqueN(ls_id)], reprotox_lincs[, uniqueN(lcs_id)]))


sql <- "SELECT
	mols_a.id mol_id_a,
	mols_b.id mol_id_b,
	ROUND(tanimoto_sml(mols_a.fp, mols_b.fp)::NUMERIC, 3) tanimoto_similarity
FROM
	(SELECT id,fp FROM mols INNER JOIN reprotox ON reprotox.mol_id = mols.id) mols_a,
	(SELECT id,fp FROM mols INNER JOIN reprotox ON reprotox.mol_id = mols.id) mols_b
WHERE
        mols_a.id < mols_b.id
ORDER BY
        mols_a.id, mols_b.id"

sims <- dbGetQuery(dbcon, sql)
setDT(sims)
plot_ly(type="histogram", x=sims[["tanimoto_similarity"]])

qs <- quantile(sims[["tanimoto_similarity"]], c(0, .25, .5, seq(.7, 1, .05)))
writeLines(sprintf("Tanimoto %4s-ile: %9.1f", names(qs), qs))
