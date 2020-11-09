#!/usr/bin/env python3

import sys,os,datetime,json,yaml,logging
import urllib.request
import pandas as pd
from pandas.io.sql import read_sql_query
#import shelve, traceback
#from functools import lru_cache
import mysql.connector as mysql

from dataclasses import dataclass, asdict

# Import C2M2 Frictionless Helper package
## dataclasses
import c2m2_frictionless
from c2m2_frictionless import create_datapackage, validate_datapackage, validate_id_namespace_name_uniqueness, build_term_tables

#from c2m2_frictionless.C2M2_Level_1 import table_schema_specs_for_level_1_c2m2_encoding_of_dcc_metadata as c2m2_level_1

from c2m2_frictionless.C2M2_Level_0 import table_schema_specs_for_level_0_c2m2_encoding_of_dcc_metadata as c2m2_level_0


def extract_transform():
  ''' Generate c2m2 level 0 dataclasses to be added to the datapackage
  '''
  # Construct the core id_namespace separating this DCC's ids from the ids of
  #  all other DCCs
  ns = c2m2_level_0.id_namespace(
    # Using a url is recommended
    # it is ideal if id_namespace + id actually resolves to a valid landing page
    id='http://www.druggablegenome.net/',
    abbreviation='IDG',
    name='IDG: Illuminating the Druggable Genome',
    description='The goal of IDG is to improve our understanding of understudied proteins from the three most commonly drug-targeted protein families: G-protein coupled receptors, ion channels, and protein kinases.',
  )
  yield ns
  #
  files = {};
  for datum in TCRD_Tables():
    try:
      # register target file if not done so already
      if datum['table'] not in files:
        f = c2m2_level_0.file(
          id_namespace=ns.id,
          id=datum['table'],
          filename=datum['table'],
          size_in_bytes=len(json.dumps(datum)),
          #persistent_id=?,
          #sha256=?,
          #md5=?,
        )
        files[datum['table']] = f
        yield f
      else:
        f = files[datum['table']]
    except Exception as e:
      logging.error('{}'.format(e))


def extract_transform_validate(outdir):
  # use the extract_transform generator to produce a datapackage
  pkg = c2m2_frictionless.create_datapackage('C2M2_Level_0', extract_transform(), outdir)
  # identify ontological terms in the datapackage, and complete the term tables
  #c2m2_frictionless.build_term_tables(outdir) # NA for Level_0?
  # validate assertion that the frictionless tableschema is complied with
  c2m2_frictionless.validate_datapackage(pkg)
  # validate assertion that (id_namespace, name) is unique in each resource
  c2m2_frictionless.validate_id_namespace_name_uniqueness(pkg)
  #
  return pkg

def ReadParamFile(fparam):
  params={};
  with open(fparam, 'r') as fh:
    for param in yaml.load_all(fh, Loader=yaml.BaseLoader):
      for k,v in param.items():
        params[k] = v
  return params

def tcrd_Connect(host=None, port=None, user=None, passwd=None, dbname=None,
	paramfile=os.environ['HOME']+"/.tcrd.yaml"):
  import mysql.connector as mysql
  params = ReadParamFile(paramfile)
  if host: params['DBHOST'] = host 
  if port: params['DBPORT'] = port 
  if user: params['DBUSR'] = user 
  if passwd: params['DBPW'] = passwd
  if dbname: params['DBNAME'] = dbname 
  try:
    dbcon = mysql.connect(host=params['DBHOST'], port=params['DBPORT'], user=params['DBUSR'], passwd=params['DBPW'], db=params['DBNAME'])
    return dbcon
  except Exception as e:
    logging.error('{}'.format(e))

def TCRD_Tables():
  dbcon = tcrd_Connect()
  df = read_sql_query("SHOW TABLES", dbcon)
  total = df.shape[0]
  df.columns = ['table']
  for i in range(total):
    table = df.iloc[i].to_dict()
    yield table

if __name__=='__main__':
  if len(sys.argv) >= 2:
    outdir = sys.argv[1]
  else:
    logging.error("OUTDIR must be specified.")
    sys.exit()
  extract_transform_validate(outdir)
