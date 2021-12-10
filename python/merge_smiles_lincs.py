#!/usr/bin/env python3
#
import sys,os,logging
import pandas as pd

if __name__=="__main__":
  logging.basicConfig(format='%(levelname)s:%(message)s', level=(logging.DEBUG))
  if len(sys.argv)<3:
    logging.error(f"Syntax: {sys.argv[0]} LINCS_RAWTSVFILE LINCS_STD_SMIFILE")
    sys.exit()

  df_raw = pd.read_csv(sys.argv[1], "\t", skiprows=1, names=["lcs_id", "pert_name", "target", "moa", "canonical_smiles", "inchi_key", "compound_aliases", "sig_count"])
  logging.info(f"{sys.argv[1]}: rows: {df_raw.shape[0]}; cols: {df_raw.shape[1]} ({','.join(list(df_raw.columns))})")

  df_smi = pd.read_csv(sys.argv[2], "\t", skiprows=1, names=["cansmi", "lcs_id"])
  logging.info(f"{sys.argv[2]}: rows: {df_smi.shape[0]}; cols: {df_smi.shape[1]} ({','.join(list(df_smi.columns))})")

  df_raw = df_raw[["lcs_id", "pert_name", "target", "moa", "inchi_key", "compound_aliases", "sig_count"]]
  logging.info(f"{sys.argv[1]}: rows: {df_raw.shape[0]}; cols: {df_raw.shape[1]} ({','.join(list(df_raw.columns))})")

  df_std = pd.merge(df_raw, df_smi, how="left", on="lcs_id")
  logging.info(f"RESULT: rows: {df_std.shape[0]}; cols: {df_std.shape[1]} ({','.join(list(df_std.columns))})")

  df_std.to_csv(sys.stdout, "\t", index=False)
