#!/usr/bin/env python3
"""
Planning to adapt this to IDG.

https://github.com/nih-cfde/FAIR/tree/master/LINCS/c2m2/README.md
https://github.com/nih-cfde/FAIR/blob/master/LINCS/c2m2/scripts/convert_to_c2m2.py
"""
###
import os,sys
import codecs
import datetime
import json
import shelve
import traceback
import urllib.request
import csv
import ipdb
import shutil
import logging
from c2m2_frictionless import create_datapackage, validate_datapackage, validate_id_namespace_name_uniqueness, build_term_tables
from c2m2_frictionless.C2M2_Level_1 import table_schema_specs_for_level_1_c2m2_encoding_of_dcc_metadata as c2m2_level_1
from dataclasses import dataclass, asdict
from functools import lru_cache #LRU = least recently used

logging.basicConfig(level=logging.DEBUG)

cache = shelve.open('.cache', 'c')

# Decorator function (modifies behavior of decorated functions)
# https://docs.python.org/3/library/functools.html
# (@lru_cache) "can save time when an expensive or I/O bound function is periodically
# called with the same arguments."
def lru_cache_on_disk(func):
  def wrapper(*args, **kwargs):
    global cache
    hashed_args = str((func.__name__, args, kwargs))
    if hashed_args not in cache:
      cache[hashed_args] = func(*args, **kwargs)
    return cache[hashed_args]
  return wrapper

@lru_cache_on_disk
def lincs_fetchdata(skip=0, limit=10):
  resp = urllib.request.urlopen(f"http://lincsportal.ccs.miami.edu/dcic/api/fetchdata?limit={limit}&searchTerm=*&skip={skip}&sort=datasetname+asc")
  assert resp.getcode() == 200
  return json.load(codecs.getreader('latin-1')(resp))

def lincs_fetchdata_iter():
  data = lincs_fetchdata()
  total = data['results']['totalDocuments']
  for document in data['results']['documents']:
    yield document
  n = len(data['results']['documents'])
  while n < total:
    data = lincs_fetchdata(skip=n)
    for document in data['results']['documents']:
      yield document
    n += len(data['results']['documents'])

@lru_cache_on_disk
def lincs_fetchcells(skip=0, limit=10):
  resp = urllib.request.urlopen(f"http://lincsportal.ccs.miami.edu/dcic/api/fetchcells?limit={limit}&searchTerm=*&skip={skip}")
  assert resp.getcode() == 200
  return json.load(codecs.getreader('latin-1')(resp))

def lincs_fetchcells_iter():
  data = lincs_fetchcells()
  total = data['results']['totalDocuments']
  for document in data['results']['documents']:
    yield document
  n = len(data['results']['documents'])
  while n < total:
    data = lincs_fetchcells(skip=n)
    for document in data['results']['documents']:
      yield document
    n += len(data['results']['documents'])

def csv_to_json(fp):
  reader = iter(csv.reader(fp, quotechar='"', delimiter=','))
  try:
    header = next(reader)
    while True:
      try:
        yield dict(zip(header, next(reader)))
      except StopIteration:
        break
  except StopIteration:
    pass

def first_or_none(it):
  try:
    return next(iter(it))
  except StopIteration:
    return None

statstypes = {
  'protein': type('StatType', tuple(), dict(
    id='lincs_subject_granularity:protein',
    include=False,
    name='protein',
    description='A protein biological entity',
    download_url=lambda datasetid: f"http://lincsportal.ccs.miami.edu/dcic/api/Results?searchTerm=%22{datasetid}%22&category=Protein",
    id_from_meta=lambda meta: meta.get('PR_UniProt_ID') or meta.get('PP_Name'),
  )),
  'cellline': type('StatType', tuple(), dict(
    id='cfde_subject_granularity:4',
    include=True,
    name='cell line',
    description='A cell line derived from one or more species or strains',
    download_url=lambda datasetid: f"http://lincsportal.ccs.miami.edu/dcic/api/Results?searchTerm=%22{datasetid}%22&category=cellline",
    id_from_meta=lambda meta: meta.get('CL_LINCS_ID'),
  )),
  'smallmolecule': type('StatType', tuple(), dict(
    id='lincs_subject_granularity:smallmolecule',
    include=False,
    name='Small Molecule',
    description='A small molecule biological entity',
    download_url=lambda datasetid: f"http://lincsportal.ccs.miami.edu/dcic/api/SmDownload?searchTerm=%22{datasetid}%22",
    id_from_meta=lambda meta: meta.get('SM_LINCS_ID'),
  )),
  'unclassper': type('StatType', tuple(), dict(
    id='lincs_subject_granularity:unclassper',
    include=False,
    name='unclassified perturbagen',
    description='An unclassified perturbagen biological entity',
    download_url=lambda datasetid: f"http://lincsportal.ccs.miami.edu/dcic/api/Results?searchTerm=%22{datasetid}%22&category=Unclassified%20Perturbagen",
    id_from_meta=lambda meta: None,
  )),
  'antibody': type('StatType', tuple(), dict(
    id='lincs_subject_granularity:antibody',
    include=False,
    name='unclassified antibody',
    description='An unclassified antibody biological entity',
    download_url=lambda datasetid: f"http://lincsportal.ccs.miami.edu/dcic/api/Results?searchTerm=%22{datasetid}%22&category=Unclassified%20Antibody",
    id_from_meta=lambda meta: None,
  )),
  'nar': type('StatType', tuple(), dict(
    id='lincs_subject_granularity:nar',
    include=False,
    name='nucleic acid reagent',
    description='A nucleic acid reagent biological entity',
    download_url=lambda datasetid: f"http://lincsportal.ccs.miami.edu/dcic/api/Results?searchTerm=%22{datasetid}%22&category=Nucleic%20Acid%20Reagent",
    id_from_meta=lambda meta: None,
  )),
  'phosphoprotein': type('StatType', tuple(), dict(
    id='lincs_subject_granularity:phosphoprotein',
    include=False,
    name='peptide probe',
    description='A peptide probe biological entity',
    download_url=lambda datasetid: f"http://lincsportal.ccs.miami.edu/dcic/api/Results?searchTerm=%22{datasetid}%22&category=Phosphoproteins",
    id_from_meta=lambda meta: meta.get('PP_UniProt_ID') or meta.get('PP_Name'),
  )),
  'differentiatediPSC': type('StatType', tuple(), dict(
    id='lincs_subject_granularity:differentiatediPSC',
    include=False,
    name='differentiated cell',
    description='A differentiated cell biological entity',
    download_url=lambda datasetid: f"http://lincsportal.ccs.miami.edu/dcic/api/Results?searchTerm=%22{datasetid}%22&category=Differentiated%20Cells",
    id_from_meta=lambda meta: None,
  )),
  'primarycell': type('StatType', tuple(), dict(
    id='lincs_subject_granularity:primarycell',
    include=False,
    name='primary cell',
    description='A primary cell biological entity',
    download_url=lambda datasetid: f"http://lincsportal.ccs.miami.edu/dcic/api/Results?searchTerm=%22{datasetid}%22&category=Primary%20Cells",
    id_from_meta=lambda meta: meta.get('PC_LINCS_ID') or meta.get('PC_Name'),
  )),
  'escell': type('StatType', tuple(), dict(
    id='lincs_subject_granularity:escell',
    include=False,
    name='embryonic stem cell',
    description='An embryonic stem cell biological entity',
    download_url=lambda datasetid: f"http://lincsportal.ccs.miami.edu/dcic/api/Results?searchTerm=%22{datasetid}%22&category=Stem%20Cell",
    id_from_meta=lambda meta: None,
  )),
  'iPSC': type('StatType', tuple(), dict(
    id='lincs_subject_granularity:iPSC',
    include=False,
    name='induced pluripotent stem cell',
    description='An induced pluripotent stem cell biological entity',
    download_url=lambda datasetid: f"http://lincsportal.ccs.miami.edu/dcic/api/Results?searchTerm=%22{datasetid}%22&category=IPSCs",
    id_from_meta=lambda meta: meta.get('IP_LINCS_ID') or meta.get('IP_Name'),
  )),
  'other': type('StatType', tuple(), dict(
    id='lincs_subject_granularity:other',
    include=False,
    name='other reagent',
    description='Other unclassified reagent biological entity',
    download_url=lambda datasetid: f"http://lincsportal.ccs.miami.edu/dcic/api/Results?searchTerm=%22{datasetid}%22&category=Other",
    id_from_meta=lambda meta: meta.get('lincsidentifier') or meta.get('OR_Name'),
  )),
}

@lru_cache_on_disk
def lincs_fetchstats(datasetid, statsfields):
  stats = {}
  if not statsfields:
    return stats
  for stat in statsfields:
    if stat not in statstypes:
      print(f"WARNING: unrecognized stat type {stat}")
      continue
    else:
      resp = urllib.request.urlopen(statstypes[stat].download_url(datasetid))
      assert resp.getcode() == 200
      stats[stat] = list(csv_to_json(codecs.getreader('latin-1')(resp)))
  return stats

lincs_assay_bao_lookup = {
  'Aggregated small molecule biochemical target activity': '',
  'ATAC-seq': 'BAO:0010038',
  'Bead-based immunoassay': 'BAO:0010050',
  'ELISA': 'BAO:0000134',
  'Fluorescence imaging': 'BAO:0010056',
  'KiNativ': 'BAO:0002908',
  'KINOMEscan': 'BAO:0003011',
  'L1000': 'BAO:0010046',
  'LC-MS': 'BAO:0010071',
  'Mass spectrometry': 'BAO:0000055',
  'MEMA (fluorescence imaging)': 'BAO:0010060',
  'Microwestern': 'BAO:0010049',
  'P100 (mass spectrometry)': 'BAO:0010063',
  'PCR': 'BAO:0003031',
  'RNA-seq': 'BAO:0010045',
  'RPPA': 'BAO:0010030',
  'SWATH-MS': 'BAO:0010028',
  'Tandem Mass Tag (TMT) Mass Spectrometry': 'BAO:0010070',
  'To Be Classified': '',
}

lincs_assay_obi_lookup = {
  'Aggregated small molecule biochemical target activity': 'OBI:0000070',
  'ATAC-seq': 'OBI:0002020',
  'Bead-based immunoassay': 'OBI:0001632',
  'ELISA': 'OBI:0001632',
  'Fluorescence imaging': 'OBI:0001501',
  'KiNativ': 'OBI:0001146',
  'KINOMEscan': 'OBI:0001146',
  'L1000': 'OBI:0000424',
  'LC-MS': 'OBI:0000470',
  'Mass spectrometry': 'OBI:0000470',
  'MEMA (fluorescence imaging)': 'OBI:0001501',
  'Microwestern': 'OBI:0000615',
  'P100 (mass spectrometry)': 'OBI:0000615',
  'PCR': 'OBI:0001146',
  'RNA-seq': 'OBI:0001271',
  'RPPA': 'OBI:0000615',
  'SWATH-MS': 'OBI:0000615',
  'Tandem Mass Tag (TMT) Mass Spectrometry': 'OBI:0000470',
  'To Be Classified': '',
}
def lincs_assay_convert(datum):
  assay_overlap = set(datum.get('assayname', [])) & lincs_assay_obi_lookup.keys()
  if assay_overlap:
    assay = next(iter(assay_overlap))
  else:
    assay = datum.get('technologies') or datum.get('assayname', ['To Be Classified'])[0]
  #
  if assay not in lincs_assay_obi_lookup:
    print(f"WARNING: {assay} not recognized in {datum}")
    return ''
  #
  return lincs_assay_obi_lookup[assay]

lincs_anatomy_lookup = {
  frozenset(): '',
  frozenset({'Ovary'}): 'UBERON:0000992',
  frozenset({'cervix'}): 'UBERON:0000002',
  frozenset({'kidney'}): 'UBERON:0002113',
  frozenset({'vulva'}): 'UBERON:0000997',
  frozenset({'gall bladder'}): 'UBERON:0002110',
  frozenset({'urinary bladder'}): 'UBERON:0001255',
  frozenset({'nervous system'}): 'UBERON:0001016',
  frozenset({'Lung'}): 'UBERON:0002048',
  frozenset({'skin'}): 'UBERON:0002097',
  frozenset({'Intestine'}): 'UBERON:0000160',
  frozenset({'Peripheral blood'}): 'UBERON:0000178', # WARNING: not 'peripheral'
  frozenset({'miscellaneous'}): '',
  frozenset({'adrenal gland'}): 'UBERON:0002369',
  frozenset({'lung'}): 'UBERON:0002048',
  frozenset({'thyroid'}): 'UBERON:0002046',
  frozenset({'urinary tract'}): 'UBERON:0011143', #'UBERON:0011143, UBERON:0001556',
  frozenset({'uterus'}): 'UBERON:0000995',
  frozenset({'pancreas'}): 'UBERON:0001264',
  frozenset({'lymphatic system'}): 'UBERON:0006558',
  frozenset({'muscle'}): 'UBERON:0001630',
  frozenset({'biliary tract'}): '',
  frozenset({'blood'}): 'UBERON:0000178',
  frozenset({'stomach'}): 'UBERON:0000945',
  frozenset({'intestine'}): 'UBERON:0000160',
  frozenset({'head and neck'}): 'UBERON:0000974', #'UBERON:0000974, UBERON:0000974',
  frozenset({'human'}): '',
  frozenset({'Brain'}): 'UBERON:0000955',
  frozenset({'testes'}): 'UBERON:0000473',
  frozenset({'bone'}): 'UBERON:0002481',
  frozenset({'large intestine'}): 'UBERON:0000059',
  frozenset({'endometrium'}): 'UBERON:0001295',
  frozenset({'ureter'}): 'UBERON:0000056',
  frozenset({'pleura'}): 'UBERON:0000977',
  frozenset({'Skin'}): 'UBERON:0002097',
  frozenset({'breast'}): 'UBERON:0000310',
  frozenset({'liver'}): 'UBERON:0002107',
  frozenset({'Mammary gland'}): 'UBERON:0001911',
  frozenset({'ovary'}): 'UBERON:0000992',
  frozenset({'prostate'}): 'UBERON:0002367',
  frozenset({'esophagus'}): 'UBERON:0001043',
  frozenset({'brain'}): 'UBERON:0000955',
}
def lincs_cellline_anatomy(cellline):
  organs = frozenset(cellline.get('organ', []))
  if organs not in lincs_anatomy_lookup:
    print(f"WARNING: {organs} not recognized in {cellline}")
    return ''
  return lincs_anatomy_lookup[organs]

lincs_organism_lookup = {
  frozenset(): '',
  frozenset('Homo sapiens'): '',
  frozenset('Homo Sapiens'): '',
  frozenset('Homo Sapien'): '',
}
def lincs_cellline_organism(cellline):
  return lincs_organism_lookup[frozenset(cellline.get('organism', []))]

def lincs_cellline_disease_doid(cellline):
  return frozenset(cellline.get('disease_detail', ['']))

def convert_lincs_to_c2m2():
  ''' Construct a set of c2m2 objects corresponding to the elements available through the LINCS API.
  '''
  ns = c2m2_level_1.id_namespace(
    id='http://www.lincsproject.org/',
    abbreviation='LINCS',
    name='Library of Integrated Network-Based Cellular Signatures',
    description='A library that catalogs changes that occur when different types of cells are exposed to a variety of agents that disrupt normal cellular functions',
  )
  yield ns
  primary_project = c2m2_level_1.project(
    id_namespace=ns.id,
    local_id='lincs',
    persistent_id='http://www.lincsproject.org/',
    abbreviation='LINCS',
    name='Library of Integrated Network-based Cellular Signatures',
    description='The Library of Integrated Network-Based Cellular Signatures (LINCS) Program aims to create a network-based understanding of biology by cataloging changes in gene expression and other cellular processes that occur when cells are exposed to a variety of perturbing agents.',
  )
  yield primary_project
  primary_contact = c2m2_level_1.primary_dcc_contact(
    project_id_namespace=primary_project.id_namespace,
    project_local_id=primary_project.local_id,
    dcc_abbreviation='LINCS',
    dcc_name='Library of Integrated Network-based Cellular Signatures',
    dcc_description='The Library of Integrated Network-Based Cellular Signatures (LINCS) Program aims to create a network-based understanding of biology by cataloging changes in gene expression and other cellular processes that occur when cells are exposed to a variety of perturbing agents.',
    dcc_url='http://www.lincsproject.org/',
    contact_name="Avi Ma'ayan",
    contact_email='avi.maayan@mssm.edu',
  )
  yield primary_contact
  projects = {}
  subjects = {}
  cellline_lookup = {}
  subject_granularities = {}
  # Add all subject granularities from `stattypes`
  for stat_key, stat in statstypes.items():
    if stat.include:
      subject_granularities[stat_key] = stat.id
  #
  # Process cell lines up front
  for datum in lincs_fetchcells_iter():
    try:
      if 'cellline' not in subjects:
        subjects['cellline'] = {}
      subjects['cellline'][datum['entityid']] = c2m2_level_1.subject(
        id_namespace=ns.id,
        local_id=datum['entityid'],
        project_id_namespace=primary_project.id_namespace,
        project_local_id=primary_project.local_id,
        persistent_id=f"http://lincsportal.ccs.miami.edu/cells/#/view/{datum['LINCS_ID']}",
        granularity=subject_granularities['cellline'],
      )
      yield subjects['cellline'][datum['entityid']]
      cellline_lookup[datum['entityid']] = datum
      # datum has 'organ', 'organism', and 'disease'
    except KeyboardInterrupt:
      cache.close()
      raise KeyboardInterrupt
    except Exception:
      cache.sync()
      traceback.print_exc(file=sys.stderr)
      ipdb.post_mortem(sys.exc_info()[2])
  #
  # Process datasets
  for datum in lincs_fetchdata_iter():
    try:
      # register project if not done so already
      if datum['projectname'] not in projects:
        project = c2m2_level_1.project(
          id_namespace=ns.id,
          local_id=datum['projectname'],
          name=datum['projectname'],
        )
        projects[datum['projectname']] = project
        yield project
        yield c2m2_level_1.project_in_project(
          parent_project_id_namespace=primary_project.id_namespace,
          parent_project_local_id=primary_project.local_id,
          child_project_id_namespace=project.id_namespace,
          child_project_local_id=project.local_id,
        )
      else:
        project = projects[datum['projectname']]
      #
      # grab creation time as iso 8601
      creation_time = datum.get('datereleased')
      if creation_time is not None:
        creation_time = datetime.datetime.strptime(
          creation_time, '%Y-%m-%d'
        ).replace(
          tzinfo=datetime.timezone.utc
        ).isoformat()
      # each dataset group has multiple datasets, so it is also a c2m2 project
      #  it also has associated with it assay information
      collection = c2m2_level_1.collection(
        id_namespace=ns.id,
        local_id=datum['datasetgroup'],
        persistent_id=f"http://lincsportal.ccs.miami.edu/datasets/view/{datum['datasetgroup']}",
        name=datum['datasetname'],
        description=datum.get('description', ''),
        creation_time=creation_time,
      )
      yield collection
      yield c2m2_level_1.collection_defined_by_project(
        collection_id_namespace=collection.id_namespace,
        collection_local_id=collection.local_id,
        project_id_namespace=project.id_namespace,
        project_local_id=project.local_id,
      )
      # a dataset_group has a number of aspects that are associated with it
      # including small molecules, proteins, cell lines, etc..
      # the only thing that really fits into C2M2 is the cell lines as independent biosamples
      dataset_group_subjects = {}
      dataset_group_biosamples = {}
      all_stats = lincs_fetchstats(datum['datasetid'], frozenset(field for field in datum.get('statsfields', []) if field in statstypes and statstypes[field].include))
      for stat_name, stats in all_stats.items():
        for stat in stats:
          subject = None
          subject_id = statstypes[stat_name].id_from_meta(stat)
          if subject_id:
            if stat_name not in subjects:
              subjects[stat_name] = {}
            if subject_id not in subjects[stat_name]:
              subjects[stat_name][subject_id] = c2m2_level_1.subject(
                id_namespace=ns.id,
                local_id=f"{stat_name}:{subject_id}",
                project_id_namespace=primary_project.id_namespace,
                project_local_id=primary_project.local_id,
                granularity=subject_granularities[stat_name],
              )
              yield subjects[stat_name][subject_id]
            #
            subject = subjects[stat_name][subject_id]
          else:
            print(f"WARNING: subject_id not found in {stat_name}: {stat}")
          #
          if subject and subject.local_id not in dataset_group_subjects:
            dataset_group_subjects[subject.local_id] = subject
            # we have a combinatorial amount of biosamples for each dataset => subject pair
            #  when considered against all other subject types; we'll only consider one
            #  biosample in C2M2 with associated assay & anatomy (the others would be redundant anyway)
            biosample = c2m2_level_1.biosample(
              id_namespace=ns.id,
              local_id=f"{datum['datasetgroup']}:{subject_id}",
              project_id_namespace=project.id_namespace,
              project_local_id=project.local_id,
              anatomy=lincs_cellline_anatomy(cellline_lookup[subject_id]) if subject_id in cellline_lookup else '',
            )
            yield biosample
            dataset_group_biosamples[biosample.local_id] = biosample
            yield c2m2_level_1.biosample_in_collection(
              biosample_id_namespace=biosample.id_namespace,
              biosample_local_id=biosample.local_id,
              collection_id_namespace=collection.id_namespace,
              collection_local_id=collection.local_id,
            )
            # the biosample was derived from this subject
            yield c2m2_level_1.biosample_from_subject(
              biosample_id_namespace=biosample.id_namespace,
              biosample_local_id=biosample.local_id,
              subject_id_namespace=subject.id_namespace,
              subject_local_id=subject.local_id,
            )
            # the subject is in the collection
            yield c2m2_level_1.subject_in_collection(
              subject_id_namespace=subject.id_namespace,
              subject_local_id=subject.local_id,
              collection_id_namespace=collection.id_namespace,
              collection_local_id=collection.local_id,
            )
      #
      # each dataset group has datasets each associated with a file, so it is a c2m2 file
      for dataset_id, dataset_version in zip(datum.get('datasetlevels', []), datum.get('latestversions', [])):
        file = c2m2_level_1.file(
          id_namespace=ns.id,
          local_id=dataset_id,
          project_id_namespace=project.id_namespace,
          project_local_id=project.local_id,
          persistent_id=f"http://lincsportal.ccs.miami.edu/datasets/view/{dataset_id}",
          # TODO: how to incorporate
          # persistent_id=f"http://lincsportal.ccs.miami.edu/dcic/api/download?path=LINCS_Data/{datum['centername']}&amp;file={dataset_id}_{dataset_version}.tar.gz",
          creation_time=creation_time,
          filename=f"{dataset_id}_{dataset_version}.tar.gz",
          assay_type=lincs_assay_convert(datum),
          mime_type='application/gzip',
        )
        yield file
        # each file is in the collection
        yield c2m2_level_1.file_in_collection(
          file_id_namespace=file.id_namespace,
          file_local_id=file.local_id,
          collection_id_namespace=collection.id_namespace,
          collection_local_id=collection.local_id,
        )
        # each file describes the biosamples
        for biosample in dataset_group_biosamples.values():
          yield c2m2_level_1.file_describes_biosample(
            file_id_namespace=file.id_namespace,
            file_local_id=file.local_id,
            biosample_id_namespace=biosample.id_namespace,
            biosample_local_id=biosample.local_id,
          )
        # each file also describes all of the subjects in the study
        for subject in dataset_group_subjects.values():
          yield c2m2_level_1.file_describes_subject(
            file_id_namespace=file.id_namespace,
            file_local_id=file.local_id,
            subject_id_namespace=subject.id_namespace,
            subject_local_id=subject.local_id,
          )
    except KeyboardInterrupt:
      cache.close()
      raise KeyboardInterrupt
    except Exception:
      cache.sync()
      traceback.print_exc(file=sys.stderr)
      ipdb.post_mortem(sys.exc_info()[2])

if __name__ == '__main__':
  outdir = sys.argv[1] if len(sys.argv) >= 2 else ''
  pkg = create_datapackage('C2M2_Level_1', convert_lincs_to_c2m2(), outdir)
  build_term_tables(outdir)
  validate_datapackage(pkg)
  validate_id_namespace_name_uniqueness(pkg)
  cache.close()
