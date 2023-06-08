#!/usr/bin/env python3
###
# https://github.com/nih-cfde/FAIR/tree/master/Demos/DatapackageMerge
# By John Erol Evangelista
###

import os,csv,json,click

def ensure_tuple(v):
  if type(v) == list:
    return tuple(v)
  elif type(v) == tuple:
    return v
  else:
    return (v,)

def parse_dialect(schema):
  if schema['path'].endswith('.csv'):
    delimiter = ','
  elif schema['path'].endswith('.tsv'):
    delimiter = '\t'
  else:
    raise NotImplementedError
  #
  return dict(
    fieldnames=[field['name'] for field in schema['schema']['fields']],
    delimiter=delimiter,
    quoting=csv.QUOTE_NONE,
    escapechar='',
    quotechar=''
  )

@click.command()
@click.argument('inputs', type=click.Path(dir_okay=True, file_okay=False, exists=True), nargs=-1)
@click.argument('output', type=click.Path(dir_okay=True, file_okay=False), nargs=1)
def datapackage_merge(inputs, output):
  if not inputs:
    click.echo('WARN: no inputs, nothing to do')
    return
  elif len(inputs) == 1:
    click.echo('WARN: only one input, no merging to be done is this what you wanted?')
  #
  click.echo(f'inputs: {len(inputs)}')
  click.echo(f'output: {output}')
  #
  complete_schema = {}
  complete_resources = {}
  pks = {}
  records = {}
  os.makedirs(output, exist_ok=True)
  for path in inputs:
    with open(os.path.join(path, 'datapackage.json'), 'r') as fr:
      pkg = json.load(fr)
    # datapackage metadata
    for k, v in pkg.items():
      if k == 'resources':
        for resource in v:
          if resource['name'] not in complete_resources:
            complete_resources[resource['name']] = resource
            pks[resource['name']] = set()
            records[resource['name']] = {}
            with open(os.path.join(output, resource['path']), 'w') as fw:
              writer = csv.DictWriter(
                fw, **parse_dialect(resource),
              )
              writer.writeheader()
          else:
            assert json.dumps(complete_resources[resource['name']]) == json.dumps(resource), f"Schema mismatch not supported: {complete_resources[resource['name']]} != {json.dumps(resource)}"
          records[resource['name']][path] = 0
          #
          with open(os.path.join(path, resource['path']), 'r') as fr:
            reader = csv.DictReader(
              fr, **parse_dialect(resource),
            )
            assert set(next(reader).values()) == {field['name'] for field in resource['schema']['fields']}, 'Field mismatch not supported or missing header'
            with open(os.path.join(output, resource['path']), 'a') as fw:
              writer = csv.DictWriter(
                fw, **parse_dialect(resource),
              )
              for record in reader:
                records[resource['name']][path] += 1
                pk = tuple(record[k] for k in ensure_tuple(resource['schema']['primaryKey']))
                if pk not in pks:
                  pks[resource['name']].add(pk)
                  writer.writerow(record)
      elif k not in complete_schema:
        complete_schema[k] = v
      else:
        assert json.dumps(complete_schema[k]) == json.dumps(v), f"Schema mismatch not supported: {complete_schema[k]} != {json.dumps(v)}"
  #
  complete_schema['resources'] = list(complete_resources.values())
  with open(os.path.join(output, 'datapackage.json'), 'w') as fw:
    json.dump(complete_schema, fw, indent=2)
  #
  # output summary
  for rc in complete_resources:
    click.echo(rc)
    total = 0
    for path, count in records[rc].items():
      click.echo(f'\t{path}: {count}')
      total += count
    click.echo(f'\ttotal: {total}')
    click.echo(f'\tdeduped: {len(pks[rc])}')

if __name__ == '__main__':
  datapackage_merge()
