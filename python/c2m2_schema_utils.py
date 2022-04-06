#!/usr/bin/env python3
###
import sys,os,argparse,logging
import json
import pandas as pd

#############################################################################
def LoadSchema(fin):
  schema = json.load(fin)
  logging.debug(json.dumps(schema, indent=2)+"\n")
  return schema

#############################################################################
def Schema2TableHeader(schema, table, fout):
  logging.info(f"Table: {table}")
  tags=None;
  for resource in schema["resources"]:
    if resource["name"]==table:
      fields = resource["schema"]["fields"]
      tags = [field["name"] for field in fields]
      break
  if tags is None:
    logging.error(f"Schema header not found for table: {table}")
  else:
    df = pd.DataFrame({tag:[] for tag in tags})
    df.to_csv(fout, "\t", index=False)

#############################################################################
def Schema2ListTables(schema, fout):
  tables = [resource["name"] for resource in schema["resources"]]
  tables.sort()
  for table in tables:
    fout.write(f"{table}\n")
  return tables

#############################################################################
if __name__=="__main__":
  OPS=["tableheader", "list_tables", ]
  parser = argparse.ArgumentParser(description='C2M2 schema utilities')
  parser.add_argument("op", choices=OPS, help="OPERATION")
  parser.add_argument("--i", dest="ifile", required=True, help="input JSON schema file (C2M2_datapackage.json)")
  parser.add_argument("--table", default="file", help="table name")
  parser.add_argument("--o", dest="ofile", help="output (TSV)")
  parser.add_argument("-v", "--verbose", action="count", default=0)
  args = parser.parse_args()

  logging.basicConfig(format='%(levelname)s:%(message)s', level=(logging.DEBUG if args.verbose>1 else logging.INFO))

  fin = open(args.ifile)
  fout = open(args.ofile, "w+") if args.ofile else sys.stdout

  if args.op=="tableheader":
    schema = LoadSchema(fin)
    Schema2TableHeader(schema, args.table, fout)

  elif args.op=="list_tables":
    schema = LoadSchema(fin)
    Schema2ListTables(schema, fout)

  else:
    parser.error(f"Unsupported operation: {args.op}")

