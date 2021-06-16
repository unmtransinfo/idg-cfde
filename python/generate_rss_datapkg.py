#!/usr/bin/env python3
'''
Submit C2M2 metadata for RSS JSON files using the cfde-submit tool.
See: https://docs.nih-cfde.org/en/latest/cfde-submit/docs/
'''

import os
import time
import shutil
import glob
from urllib.request import urlretrieve
import hashlib
import uuid
import csv

C2M2_TSV_DIR = '../C2M2'
C2M2_SCHEMA_URL = 'https://osf.io/e5tc2/download'
C2M2_SCHEMA_FILE = f'{SUBMISSION_DIR}/C2M2_datapackage.json'
RSS_JSON_FILE_GLOB = '../RSS_JSON/*.json'
SUBMISSION_DIR = '../data/DRGC-Resources/submission'
METADATA_FILE = '../data/DRGC_Resources_c2mc.tsv'
FILE_HEADER = 
# constant metadata values for all RSS files
ID_NAMESPACE = "cfde_idg"
PROJECT_ID_NAMESPACE = 'cfde_idg_rss'
PROJECT_LOCAL_ID = 'idgrss'
CREATION_TIME = time.strftime("%Y-%m-%d")
FILE_FORMAT = "format:3464" # http://edamontology.org/format_3464
MIME_TYPE = 'application/json'


def run():
  # get (latest) datapackage schema file
  if os.path.exists(C2M2_SCHEMA_FILE):
    os.remove(C2M2_SCHEMA_FILE)
  print(f'Downloading C2M2 datapackage schema file: {C2M2_SCHEMA_FILE}')
  urlretrieve(C2M2_SCHEMA_URL, C2M2_SCHEMA_FILE)

  # Write headers (blank tables) for all C2M2 TSVs
  # See: https://osf.io/rdeks/
  print(f'Writing headers (blank tables) for C2M2 TSVs...')
  ct = 0
  for srcf in glob.glob(f'{C2M2_TSV_DIR}/*.tsv'):
    ct += 1
    destf = '{}/{}'.format(SUBMISSION_DIR, os.path.basename(srcf))
    print(f'  {ct}. {destf}')
    shutil.copyfile(srcf, destf)
  print('Done.')
  
  # Generate the C2M2 metadata file for the RSS files
  print(f'Generating RSS Files C2M2 metadata file...')
  with open(METADATA_FILE, 'w') as ofh:
    csvwriter = csv.writer(ofh, delimiter='\t', quotechar='"', quoting=csv.QUOTE_MINIMAL)
    csvwriter.writerow(['id_namespace',	'local_id', 'project_id_namespace', 'project_local_id',
               'persistent_id', 'creation_time', 'size_in_bytes', 'uncompressed_size_in_bytes',
               'sha256', 'md5', 'filename', 'file_format', 'data_type', 'assay_type', 'mime_type'])
    row_ct = 1
    for f in glob.glob(RSS_JSON_FILE_GLOB):
      local_id = os.path.basename(f).replace('.json', '')
      persistant_id = str(uuid.uuid4())
      fsb = os.path.getsize(f)
      fsha256 = get_sha256(f)
      csvwriter.writerow( [ID_NAMESPACE, local_id, ID_NAMESPACE, PROJECT_LOCAL_ID,
                persistant_id, CREATION_TIME, fsb, fsb,
                fsha256, '', '', '', MIME_TYPE] )
      row_ct += 1
  print(f'  Wrote {row_ct} RSS file metadata lines to {METADATA_FILE}')
  destf = f'{SUBMISSION_DIR}/file.tsv'
  shutil.copyfile(METADATA_FILE, destf)
  print(f'Copied RSS metadata file to {destf}')

  # Generate the other files required for submission
  # See: https://github.com/nih-cfde/published-documentation/wiki/C2M2-Table-Summary
  MISC_FILES = {
    'id_namespace.tsv': {
      'header': ['id', 'abbreviation', 'name', 'description'],
      'data': [PROJECT_ID_NAMESPACE, 'IDGRSS', 'IDG Resources', 'IDG Resource Submission System'] },
    'primary_dcc_contact.tsv': {              
      'header': ['contact_email', 'contact_name', 'project_id_namespace', 'project_local_id', 'dcc_abbreviation', 'dcc_name', 'dcc_description', 'dcc_url'],
      'data': ['smathias@salud.unm.edu', 'Steve Mathias', PROJECT_ID_NAMESPACE, PROJECT_LOCAL_ID, 'idg', 'IDG', 'Illuminating the Druggable Genome (IDG)', 'https://druggablegenome.net'] },
    'project.tsv': {
      'header': ['id_namespace', 'local_id', 'persistent_id', 'creation_time', 'abbreviation', 'name', 'description'],
      'data': [PROJECT_ID_NAMESPACE, PROJECT_LOCAL_ID, 'idg_rss_files', CREATION_TIME, 'rssfiles', 'idg_rss_files', 'IDG RSS resource files'] },
    'file_format.tsv': {
      'header': ['id', 'name', 'description'],
      'data': [FILE_FORMAT, 'JSON', 'JavaScript Object Notation'] },
    }
  print('Generating remaining files required for submission...')
  for fn in MISC_FILES.keys():
    fp = f'{SUBMISSION_DIR}/{fn}'
    with open(fp, 'w') as ofh:
      csvwriter = csv.writer(ofh, delimiter='\t', quotechar='"', quoting=csv.QUOTE_MINIMAL)
      csvwriter.writerow(MISC_FILES[fn]['header'])
      csvwriter.writerow([MISC_FILES[fn]['data']])
    print(f'  Wrote file {fp}')
  print('Done.')

def get_sha256(filepath):
  sha256_hash = hashlib.sha256()
  with open(filepath, "rb") as ifh:
    # Read file in blocks of 4K and update hash value
    for byte_block in iter(lambda: ifh.read(4096),b""):
      sha256_hash.update(byte_block)
  return sha256_hash.hexdigest()



# #cfde-submit run --help
# cfde-submit login
# cfde-submit run $DATAPATH \
# 	--dcc-id cfde_registry_dcc:idg \
# 	--output-dir $DATADIR/submission_output \
# 	--verbose
# #
# #	--dry-run \
# #
# cfde-submit status
