#!/usr/bin/env python3
###
# FIX! See ENSG00000135443.
###

import sys,os,csv,logging
import tqdm
import pandas as pd

logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.INFO)


if len(sys.argv) != 2:
  logging.error(f"Syntax: {sys.argv[0]} GENE_TSV_FILE")
  sys.exit(1)

def Longest(txts):
  if not txts or len(txts)<1: return None
  ltxt = txts[0]
  for txt in txts[1:]:
    if len(txt)>len(ltxt): ltxt = txt
  logging.debug(f"Longest = {ltxt}")
  return ltxt

ifile = sys.argv[1]

###
# gene.tsv columns: id, name, description, synonyms, organism

df_in = pd.read_csv(ifile, sep="\t")

logging.info(f"Input columns: {df_in.columns.to_list()}; rows: {df_in.shape[0]}; cols: {df_in.shape[1]}")

logging.info(f"{df_in.describe()}")

# Merge rows with duplicate IDs (ENSG). Keep longest synonyms and description
# fields. Keep first name (symbol) and organism field.

df_out = pd.DataFrame({"id":sorted(df_in.id.unique()), "name":None, "description":None, "synonyms":None, "organism":None})
logging.info(f"Output columns: {df_out.columns.to_list()}; rows: {df_out.shape[0]}; cols: {df_out.shape[1]}")

tq = tqdm.tqdm(total=df_out.id.shape[0])

n_rows_merged=0

for i,id_this in enumerate(df_out.id):
  tq.update(1)
  if df_in.loc[df_in['id'] == id_this].shape[0]>1:
      n_rows_merged += (df_in.loc[df_in['id'] == id_this].shape[0]-1)
  df_out.loc[df_out['id'] == id_this, ['synonyms']] = Longest(df_in.loc[df_in['id'] == id_this].synonyms.to_list())
  df_out.loc[df_out['id'] == id_this, ['description']] = Longest(df_in.loc[df_in['id'] == id_this].description.to_list())
  df_out.loc[df_out['id'] == id_this, ['name']] = df_in.loc[df_in['id'] == id_this].name.to_list()[0]
  df_out.loc[df_out['id'] == id_this, ['organism']] = df_in.loc[df_in['id'] == id_this].organism.to_list()[0]
  df_out_this = df_out[df_out['id'] == id_this]
  df_out_this.to_csv(sys.stdout, sep="\t", header=bool(i==0), index=False, quoting=csv.QUOTE_NONE)

tq.close()

logging.info(f"Input rows: {df_in.shape[0]}; output IDs/rows: {i}; rows merged: {n_rows_merged}")
