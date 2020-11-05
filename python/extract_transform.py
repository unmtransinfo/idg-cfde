#!/usr/bin/env python3

import sys, os, datetime, json, shelve, traceback
import urllib.request
import pandas as pd

from dataclasses import dataclass, asdict
from functools import lru_cache

# Import C2M2 Frictionless Helper package
## dataclasses
import c2m2_frictionless
from c2m2_frictionless import create_datapackage, validate_datapackage, validate_id_namespace_name_uniqueness, build_term_tables

#from c2m2_frictionless.C2M2_Level_1 import table_schema_specs_for_level_1_c2m2_encoding_of_dcc_metadata as c2m2_level_1

from c2m2_frictionless.C2M2_Level_0 import table_schema_specs_for_level_0_c2m2_encoding_of_dcc_metadata as c2m2_level_0

# For TCRD access:
import BioClients.idg.tcrd as idg_tcrd
import BioClients.util.yaml as util_yaml
import mysql.connector as mysql


def extract_transform():
  ''' Generate c2m2 level 0 dataclasses to be added to the datapackage
  '''
  # Construct the core id_namespace separating this DCC's ids from the ids of
  #  all other DCCs
  ns = c2m2_level_0.id_namespace(
    # Using a url is recommended
    # it is ideal if id_namespace + id actually resolves to a valid landing page
    id='http://pharos.nih.gov/',
    abbreviation='IDG',
    name='IDG: Illuminating the Druggable Genome',
    description='The goal of IDG is to improve our understanding of understudied proteins from the three most commonly drug-targeted protein families: G-protein coupled receptors, ion channels, and protein kinases.',
  )
  yield ns
  # TODO: yield additional models

def extract_transform_validate(outdir):
  # use the extract_transform generator to produce a datapackage
  pkg = c2m2_frictionless.create_datapackage('C2M2_Level_0', extract_transform(), outdir)
  # identify ontological terms in the datapackage, and complete the term tables
  c2m2_frictionless.build_term_tables(outdir)
  # validate assertion that the frictionless tableschema is complied with
  c2m2_frictionless.validate_datapackage(pkg)
  # validate assertion that (id_namespace, name) is unique in each resource
  c2m2_frictionless.validate_id_namespace_name_uniqueness(pkg)
  #
  return pkg

def TCRD_Tables():
  param_file = os.environ['HOME']+"/.tcrd.yaml"
  params = util_yaml.ReadParamFile(param_file)
  dbcon = mysql.connect(host=params['DBHOST'], port=params['DBPORT'], user=params['DBUSR'], passwd=params['DBPW'], db=params['DBNAME'])
  df = idg_tcrd.Utils.DescribeTables(dbcon)
  df.to_csv(sys.stdout, "\t", index=False)

if __name__=='__main__':

# TCRD_Tables()

  # output directory from command line
  extract_transform_validate(sys.argv[1] if len(sys.argv) >= 2 else '.')
