#!/usr/bin/env python3
'''
Generate a JSON file for each Pharos-ready resource currently in the RSS system.
File names are: <RSS ID>.json
'''

import requests
import json

RSS_API_BASE_URL = 'https://rss.ccs.miami.edu/rss-api/'
OUTDIR = '../RSS_JSON'

def run():
  target_data = get_target_data()
  assert target_data, "Error getting target data: FATAL"
  ct = 0
  pr_ct = 0
  fo_ct = 0
  for td in target_data:
    ct += 1
    if not td['pharosReady']: # Pharos-ready filter
      continue
    pr_ct += 1
    resource_data = get_resource_data(td['id'])
    if not resource_data:
      print("Error getting resource data for {}: Skipping".format(td['id']))
      continue
    # Write resource metadata to a file
    rid = td['id'].rsplit('/')[-1]
    ofn = "{}/{}.json".format(OUTDIR, rid)
    with open(ofn, 'w') as ofh:
      json.dump(resource_data['data'][0], ofh)
      fo_ct += 1
  print("Processed {} RSS resources".format(ct))
  print("  Got {} Pharos-ready resources".format(pr_ct))
  print("  Wrote {} JSON files".format(fo_ct))

def get_target_data():
  url = RSS_API_BASE_URL + 'target'
  jsondata = None
  attempts = 0
  resp = requests.get(url, verify=False)
  if resp.status_code == 200:
    return resp.json()
  else:
    return False

def get_resource_data(idval):
  url = RSS_API_BASE_URL + 'target/id?id=%s'%idval
  jsondata = None
  attempts = 0
  resp = requests.get(url, verify=False)
  if resp.status_code == 200:
    return resp.json()
  else:
    return False


if __name__ == '__main__':
  run()
