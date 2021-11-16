#!/usr/bin/env python3
#
import sys,os
import pandas as pd

fname = "LS_Mapping_PubChem-CID.tsv"
df_ls = pd.read_csv(fname, "\t")
print(f"{fname}: rows: {df_ls.shape[0]}")
print(f"{fname}: unique CIDs: {df_ls.CID.nunique()}")

fname = "SM_LINCS_10272021.tsv"
df_lincs = pd.read_csv(fname, "\t")
print(f"{fname}: rows: {df_lincs.shape[0]}")
print(f"{fname}: unique CIDs: {df_lincs.SM_PubChem_CID.nunique()}")

cids_ls = df_ls.CID.tolist()
cids_lincs = df_lincs.SM_PubChem_CID.tolist()

cids_ls_in_lincs = set(cids_ls) & set(cids_lincs)

print(f"CIDS from Leadscope in LINCS: {len(cids_ls_in_lincs)}")
