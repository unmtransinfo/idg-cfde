#!/usr/bin/env python3

import os
import glob
import hashlib
import csv

INPUT_GLOB = '../RSS_JSON/*.json'
OUTPUT_FILE = '../RSS_JSON/DRGC_Resources_test.tsv'
HEADER = ['id_namespace', 'local_id', 'persistent_id', 'size_in_bytes', 'sha256', 'md5', 'filename']

def run():
  with open(OUTPUT_FILE, 'w') as csvout:
    csvwriter = csv.writer(csvout, delimiter='\t', quotechar='"', quoting=csv.QUOTE_MINIMAL)
    csvwriter.writerow(HEADER)
    row_ct = 1
    for f in glob.glob(INPUT_GLOB):
      outrow =['IDG'] # id_namespace
      outrow.append(os.path.basename(f).replace('.json', '')) # local_id
      outrow.append('DOI:ARK:WHATEVER_{:0>10}'.format(row_ct)) # persistant_id ???
      outrow.append(os.path.getsize(f)) # size_in_bytes
      outrow.append(get_sha256(f)) # sha256
      outrow.append('') # md5 not required
      outrow.append(os.path.basename(f)) # filename
      csvwriter.writerow(outrow)
      row_ct += 1
  print("Wrote {} lines to output file {}".format(row_ct, OUTPUT_FILE))

def get_sha256(filepath):
  sha256_hash = hashlib.sha256()
  with open(filepath, "rb") as ifh:
    # Read file in blocks of 4K and update hash value
    for byte_block in iter(lambda: ifh.read(4096),b""):
      sha256_hash.update(byte_block)
  return sha256_hash.hexdigest()


if __name__ == '__main__':
  run()
