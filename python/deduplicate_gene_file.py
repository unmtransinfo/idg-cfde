#!/usr/bin/env python3
###

import sys,os,csv
import tqdm
import pandas as pd


if len(sys.argv) != 2:
  print(f"ERROR: Syntax: {sys.argv[0]} GENE_TSV_FILE")
  sys.exit(1)

def Longest(txts):
  if not txts or len(txts)<1: return None
  ltxt = txts[0]
  for txt in txts[1:]:
    if len(txt)>len(ltxt): ltxt = txt
  #print(f"DEBUG: Longest = {ltxt}")
  return ltxt

ifile = sys.argv[1]

###
# gene.tsv columns: id, name, description, synonyms, organism

df_in = pd.read_csv(ifile, sep="\t")

print(f"Input columns: {df_in.columns.to_list()}; rows: {df_in.shape[0]}; cols: {df_in.shape[1]}", file=sys.stderr)

print(f"{df_in.describe()}", file=sys.stderr)

# Merge rows with duplicate IDs (ENSG). Keep longest synonyms and description
# fields. Keep first name (symbol) and organism field.

df_out = pd.DataFrame({"id":sorted(df_in.id.unique()), "name":None, "description":None, "synonyms":None, "organism":None})
print(f"Output columns: {df_out.columns.to_list()}; rows: {df_out.shape[0]}; cols: {df_out.shape[1]}", file=sys.stderr)

tq = tqdm.tqdm(total=df_out.id.shape[0])

for i,id_this in enumerate(df_out.id):
  tq.update(1)
  df_out.loc[df_in['id'] == id_this, ['synonyms']] = Longest(df_in.loc[df_in['id'] == id_this].synonyms.to_list())
  df_out.loc[df_in['id'] == id_this, ['description']] = Longest(df_in.loc[df_in['id'] == id_this].description.to_list())
  df_out.loc[df_in['id'] == id_this, ['name']] = df_in.loc[df_in['id'] == id_this].name.to_list()[0]
  df_out.loc[df_in['id'] == id_this, ['organism']] = df_in.loc[df_in['id'] == id_this].organism.to_list()[0]
  df_out_this = df_out[df_in['id'] == id_this]
  df_out_this.reindex()
  df_out_this.to_csv(sys.stdout, sep="\t", header=bool(i==0), index=False, quoting=csv.QUOTE_NONE)

tq.close()

print(f"Output IDs/rows: {i}", file=sys.stderr)
