#!/usr/bin/env python3
###
import sys,os,argparse,logging
import json
import pandas as pd

#############################################################################
def Schema2TsvHeader(fin, table, fout):
  tags=None;
  schema = json.load(fin)
  logging.debug(json.dumps(schema, indent=2)+"\n")
  for resource in schema["resources"]:
    if resource["name"]==table:
      fields = resource["schema"]["fields"]
      tags = [field["name"] for field in fields]
      break
  if tags is None:
    logging.error(f"Schema not found for table: {table}")
  else:
    df = pd.DataFrame({tag:[] for tag in tags})
    df.to_csv(fout, "\t", index=False)

#############################################################################
if __name__=="__main__":
  parser = argparse.ArgumentParser(description='C2M2 schema JSON to TSV header converter')
  parser.add_argument("--i", dest="ifile", required=True, help="input JSON schema file (C2M2_datapackage.json)")
  parser.add_argument("--table", required=True, help="table name")
  parser.add_argument("--o", dest="ofile", help="output (TSV)")
  parser.add_argument("-v", "--verbose", action="count", default=0)
  args = parser.parse_args()

  logging.basicConfig(format='%(levelname)s:%(message)s', level=(logging.DEBUG if args.verbose>1 else logging.INFO))

  fin = open(args.ifile)

  fout = open(args.ofile, "w+") if args.ofile else sys.stdout

  Schema2TsvHeader(fin, args.table, fout)
