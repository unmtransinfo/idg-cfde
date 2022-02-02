#!/usr/bin/env python3
###
import sys,os,re,json

with open("C2M2_datapackage.json", "r") as fin:
  json_txt = fin.read()

schema = json.loads(json_txt)

for resource in schema['resources']:
  print(f"{resource['name']}\t{resource['path']}\t{resource['description']}")
