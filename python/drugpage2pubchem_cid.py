#!/usr/bin/env python3
###
import sys,json
d = json.load(sys.stdin)
x = set([xref['xref'] if xref['xref_type']=="PUBCHEM_CID" else None for xref in d['xrefs']])
if None in x: x.remove(None)
x = list(x)
print(x[0] if len(x)>0 else "")
