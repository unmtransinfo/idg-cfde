#!/usr/bin/env python3

import requests
import json

RSS_API_BASE_URL = 'https://rss.ccs.miami.edu/rss-api/'

def run():
  target_data = get_target_data()
  assert target_data, "Error getting target data"
  ct = 0
  pr_ct = 0
  for td in target_data:
    ct += 1
    if not td['pharosReady']:
      continue
    pr_ct += 1
    #print(td)
    resource_data = get_resource_data(td['id'])
    assert resource_data, "Error getting resource data for {}".format(td['id'])
    #print(resource_data)
    for key,val in resource_data['data'][0].items():
      print("{}: {}".format(key, val))
      # # Write resource metadata to a file
      # ofn = "{}.json".format(resource_data['data'][0]['name'])
      # with open(ofn, 'w') as ofh:
      #   json.dump(resource_data['data'][0], ofh)
    break

  
  

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
