#!/usr/bin/env python3
"""
Planning to adapt this to IDG.

https://github.com/nih-cfde/FAIR/tree/master/LINCS/c2m2/README.md
https://github.com/nih-cfde/FAIR/blob/master/LINCS/c2m2/scripts/convert_to_c2m2.py
"""
###
import os,sys
import datetime
import ipdb,traceback
import json,logging,yaml,re
from pandas.io.sql import read_sql_query
import urllib.request

from c2m2_frictionless import create_datapackage, validate_datapackage, validate_id_namespace_name_uniqueness
from c2m2_frictionless.C2M2_Level_0 import table_schema_specs_for_level_0_c2m2_encoding_of_dcc_metadata as c2m2_level_0
#from c2m2_frictionless.C2M2_Level_1 import table_schema_specs_for_level_1_c2m2_encoding_of_dcc_metadata as c2m2_level_1
from dataclasses import dataclass, asdict

#import codecs
#import shutil
#import csv
#import shelve
#from functools import lru_cache #LRU = least recently used

logging.basicConfig(level=logging.DEBUG)

#cache = shelve.open('.cache', 'c')

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

def tcrd_fetchdata_iter():
  sql='''
SELECT
	target.id tcrdTargetId,
	target.name tcrdTargetName,
	target.fam tcrdTargetFamily,
	target.tdl TDL,
	target.ttype tcrdTargetType,
	target.idg idgList,
	protein.id tcrdProteinId,
	protein.sym tcrdGeneSymbol,
	protein.family tcrdProteinFamily,
	protein.geneid ncbiGeneId,
	protein.uniprot uniprotId,
	protein.up_version uniprotVersion,
	protein.chr,
	protein.description tcrdProteinDescription,
	protein.dtoid dtoId,
	protein.dtoclass dtoClass,
	protein.stringid ensemblProteinId
FROM
	target
JOIN
	t2tc ON t2tc.target_id = target.id
JOIN
	protein ON protein.id = t2tc.protein_id
'''
  dbcon = tcrd_Connect()
  df = read_sql_query(sql, dbcon)
  total = df.shape[0]
  logging.info("Targets: {}".format(total))
  NMAX=10;
  for i in range(total):
    #if i>NMAX: break
    target = df.iloc[i].to_dict()
    yield target

def convert_tcrd_to_c2m2():
  ''' Construct a set of c2m2 objects corresponding to datasets available from TCRD.
  '''
  ns = c2m2_level_0.id_namespace(
    id='http://www.druggablegenome.net/',
    abbreviation='IDG',
    name='Illuminating the Druggable Genome',
    description='The goal of IDG is to improve our understanding of understudied proteins from the three most commonly drug-targeted protein families: G-protein coupled receptors, ion channels, and protein kinases.',
  )
  yield ns
  #
  files = {}
  # Process files for datum in tcrd_fetchdata_iter():
  for datum in tcrd_fetchdata_iter():
    try:
      # register target file if not done so already
      if datum['tcrdTargetName'] not in files:
        f = c2m2_level_0.file(
          id_namespace=ns.id,
          id=datum['tcrdTargetId'],
          filename=datum['tcrdTargetName'],
          size_in_bytes=len(json.dumps(datum)),
          #persistent_id=?,
          #sha256=?,
          #md5=?,
        )
        files[datum['tcrdTargetName']] = f
        yield f
      else:
        f = files[datum['tcrdTargetName']]
    except Exception as e:
      logging.error('{}'.format(e))


if __name__ == '__main__':
  if len(sys.argv) >= 2:
    outdir = sys.argv[1]
  else:
    logging.error("OUTDIR must be specified.")
    sys.exit()
  pkg = create_datapackage('C2M2_Level_0', convert_tcrd_to_c2m2(), outdir)
  #build_term_tables(outdir) #NA for Level_0?
  validate_datapackage(pkg)
  validate_id_namespace_name_uniqueness(pkg)
  #cache.close()
