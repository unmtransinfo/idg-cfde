#!/usr/bin/env python3
###
import sys,json
d = json.load(sys.stdin)
x = set([xref['xref'] if xref['xref_type']=="PUBCHEM_CID" else None for xref in d['xrefs']])
x.remove(None)
x = list(x)
if len(x)==0:
  print("")
else:
  print(x[0])
