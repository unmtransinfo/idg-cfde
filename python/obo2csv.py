#! /usr/bin/env python3
"""
	obo2csv.py - used on doid.obo (Disease Ontology)
"""
import sys,os,argparse,re,logging

#############################################################################
def OBO2CSV(fin, fout):
  n_in=0; n_rec=0; n_out=0;
  tags = ['id', 'name', 'namespace', 'alt_id', 'def', 'subset', 'synonym', 'xref', 'is_a', 'is_obsolete']
  fout.write('\t'.join(tags)+'\n')
  reclines=[];
  while True:
    line=fin.readline()
    if not line: break
    n_in+=1
    line=line.strip()
    if reclines:
      if line == '':
        row = OBO2CSV_Record(reclines)
        n_rec+=1
        vals=[]
        is_obsolete=False
        for tag in tags:
          if tag in row:
            val=row[tag]
            if tag in ('def', 'synonym'):
              val=re.sub(r'^"([^"]*)".*$', r'\1', val)
            else:
              val=re.sub(r'^"(.*)"$', r'\1', val)
          else:
            val=''
          if tag=='is_obsolete': is_obsolete = bool(val.lower() == "true")
          vals.append(val)
        if not is_obsolete:
          fout.write('\t'.join(vals)+'\n')
          n_out+=1
        reclines=[];
      else:
        reclines.append(line)
    else:
      if line == '[Term]':
        reclines.append(line)
      else: continue

  logging.info(f"input lines: {n_in}; input records: {n_rec} ; output lines: {n_out}")

#############################################################################
def OBO2CSV_Record(reclines):
  vals={};
  if reclines[0] != '[Term]':
    logging.error(f"reclines[0] = '{reclines[0]}'")
    return
  for line in reclines[1:]:
    line = re.sub(r'\s*!.*$','',line)
    k,v = re.split(r':\s*', line, maxsplit=1)
    if k=='xref' and not re.match(r'\S+:\S+$',v): continue
    if k not in vals: vals[k]=''
    vals[k] = f"{vals[k]}{';' if vals[k] else ''}{v}"
  return vals

#############################################################################
if __name__=='__main__':
  parser = argparse.ArgumentParser(description='OBO to TSV converter')
  parser.add_argument("--i", dest="ifile", required=True, help="input OBO file")
  parser.add_argument("--o", dest="ofile", help="output (TSV)")
  parser.add_argument("-v", "--verbose", action="count", default=0)
  args = parser.parse_args()

  logging.basicConfig(format='%(levelname)s:%(message)s', level=(logging.DEBUG if args.verbose>1 else logging.INFO))

  fin = open(args.ifile)

  fout = open(args.ofile, "w+") if args.ofile else sys.stdout

  OBO2CSV(fin, fout)
