#!/usr/bin/env python3
###
# https://plotly.com/python/sunburst-charts/
# https://docs.scipy.org/doc/scipy/reference/generated/scipy.cluster.hierarchy.linkage.html
###
import sys,os,argparse,logging
import pandas as pd
import plotly.graph_objects as pgo

logging.basicConfig(format='%(levelname)s:%(message)s', level=(logging.INFO))

# Input linkage matrix (Scipy format).
df = pd.read_csv("data/ReproTox_kg_compounds_lincs_clusters_lmat.tsv", "\t")
metadata = pd.read_csv("data/ReproTox_kg_compounds_lincs.tsv", "\t")
N = df.shape[0] + 1 #Individual count
N_clusters = max(max(df.idxa), max(df.idxb)) - N + 1 #Cluster count
logging.debug(f"N = {N}; N_clusters = {N_clusters}; N+N_clusters = {N+N_clusters}")
df_display = pd.DataFrame(dict(ids = range(N+N_clusters), labels = None, parents = None))
for i in range(N):
  df_display.loc[i, "labels"] = metadata.pert_name[i]
for i in range(N_clusters):
  df_display.loc[N+i, "labels"] = f"Cluster_{N+i:03d}"
for i in range(df.shape[0]):
  logging.debug(f"{i}. PARENT({df.idxa[i]}, {df.idxb[i]}) = {N+i}")
  if df.idxa[i]>df_display.shape[0]-1:
    logging.error(f"{df.idxa[i]}>{df_display.shape[0]-1}")
  else:
    df_display.loc[df.idxa[i], "parents"] = N+i
  if df.idxb[i]>df_display.shape[0]-1:
    logging.error(f"{df.idxb[i]}>{df_display.shape[0]-1}")
  else:
    df_display.loc[df.idxb[i], "parents"] = N+i
  
#df_display.to_csv(sys.stderr, "\t", index=False)

fig = pgo.Figure()

fig.add_trace(pgo.Sunburst(
    ids = df_display.ids,
    labels = df_display.labels,
    parents = df_display.parents,
    domain = dict(column=0),
    maxdepth = 5
))
fig.add_trace(pgo.Sunburst(
    ids = df_display.ids,
    labels = df_display.labels,
    parents = df_display.parents,
    domain = dict(column=1),
    maxdepth = 8
))

fig.update_layout(
    grid = dict(columns=2, rows=1),
    margin = dict(t=0, l=0, r=0, b=0)
)

fig.show()
