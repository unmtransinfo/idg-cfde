#!/usr/bin/env python3
###
# https://plotly.com/python/sunburst-charts/
# https://docs.scipy.org/doc/scipy/reference/generated/scipy.cluster.hierarchy.linkage.html
###
import sys,os,random,argparse,logging
import pandas as pd
import plotly.graph_objects as pgo

if __name__=="__main__":
  parser = argparse.ArgumentParser(description="Plotly sunburst from Scikit-learn agglomerative clusters via linkage matrix (Scipy format)")
  parser.add_argument("--i", dest="ifile", help="input linkage matrix file (CSV|TSV)")
  parser.add_argument("--i_meta", dest="ifile_meta", help="input metadata file (CSV|TSV)")
  parser.add_argument("--o_html", dest="ofile_html", help="output plot as HTML (interactive)")
  parser.add_argument("--o_img", dest="ofile_img", help="output plot as static image (PNG|JPEG|SVG|PDF|EPS)")
  parser.add_argument("--tsv", action="store_true", help="input file TSV")
  parser.add_argument("--delim", default=",", help="use if not comma or tab")
  parser.add_argument("--display", action="store_true", help="Show plot interactively.")
  parser.add_argument("-v", "--verbose", default=0, action="count")
  args = parser.parse_args()

  logging.basicConfig(format='%(levelname)s:%(message)s', level=(logging.DEBUG if args.verbose>1 else logging.INFO))

  DELIM = '\t' if args.tsv else args.delim

  # Input linkage matrix (Scipy format).
  df = pd.read_csv(args.ifile, sep=DELIM)
  metadata = pd.read_csv(args.ifile_meta, sep=DELIM)
  N = df.shape[0] + 1 #Individual count
  N_clusters = max(max(df.idxa), max(df.idxb)) - N + 1 #Cluster count
  logging.debug(f"N = {N}; N_clusters = {N_clusters}; N+N_clusters = {N+N_clusters}")
  df_display = pd.DataFrame(dict(ids=range(N+N_clusters), label=None, parent=None, value=None, color=None))
  for i in range(N):
    df_display.loc[i, "label"] = metadata.pert_name[i]
    df_display.loc[i, "value"] = 1
  for i in range(N_clusters):
    df_display.loc[N+i, "label"] = f"Cluster_{N+i:03d}"
    #df_display.loc[N+i, "color"] = "red" #DEBUG
    df_display.loc[N+i, "color"] = random.randint(1, 12) #DEBUG
    #df_display.loc[N+i, "color"] = random.randint(1, 5) #DEBUG
  for i in range(df.shape[0]):
    logging.debug(f"{i}. PARENT({df.idxa[i]}, {df.idxb[i]}) = {N+i}")
    if df.idxa[i]>df_display.shape[0]-1:
      logging.error(f"{df.idxa[i]}>{df_display.shape[0]-1}")
    else:
      df_display.loc[df.idxa[i], "parent"] = N+i
    if df.idxb[i]>df_display.shape[0]-1:
      logging.error(f"{df.idxb[i]}>{df_display.shape[0]-1}")
    else:
      df_display.loc[df.idxb[i], "parent"] = N+i
    if N+i<df_display.shape[0]:
      df_display.loc[N+i, "value"] = df.n[i]

  #df_display.to_csv(sys.stderr, "\t", index=False)

  fig = pgo.Figure()

  fig.add_trace(pgo.Sunburst(
	domain = dict(column=0),
	ids = df_display.ids,
	labels = df_display.label,
	parents = df_display.parent,
	maxdepth = 5
	))
  fig.add_trace(pgo.Sunburst(
	domain = dict(column=1),
	ids = df_display.ids,
	labels = df_display.label,
	parents = df_display.parent,
	marker = dict(
		colors = df_display.color,
		colorscale='RdBu', ),
	values = df_display.value,
	hovertemplate = '<b>Label:</b> %{label} <br /><b>Count:</b> %{value}',
	maxdepth = 8
	))
  fig.update_layout(
	grid = dict(columns=2, rows=1),
	margin = dict(t=0, l=0, r=0, b=0)
	)

  if args.ofile_html is not None:
    fig.write_html(args.ofile_html)

  if args.ofile_img is not None:
    fig.write_image(args.ofile_img) #PNG|JPEG|SVG|PDF|EPS (requires kaleido)

  if args.display:
    fig.show()

