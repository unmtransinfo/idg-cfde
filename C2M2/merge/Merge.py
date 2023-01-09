#!/usr/bin/env python3
"""
CFDE Datapackage Merge
 
How to use
1. Download the latest preparation script, prepare_C2M2_submission.py (https://osf.io/c67sp), as well as the external vocabulary table
2. `pip install -r requirements.txt`
3. Edit indir (cell 2) and outdir (cell 15) 
4. Run all cells
5. `cfde-submit run <directory_to_submit (outdir)> --output-dir=<new_output_directory> --dcc idg`
"""

## pip3 install 'c2m2-frictionless-dataclass[full] @ git+https://github.com/nih-cfde/c2m2-frictionless-dataclass'

import os
from os.path import exists
import csv
import json
import pandas as pd
from datapackage import DataPackage
from dotenv import load_dotenv
import requests
from c2m2_frictionless import C2M2, create_datapackage, validate_datapackage, validate_id_namespace_name_uniqueness, build_term_tables
import time
import tqdm
import glob


# In[2]:
indir = "06152022"
namespace = "https://www.druggablegenome.net/"

# In[3]:
def yield_id_namespace():
    for inputpath in glob.glob(indir + "data_*"):
        id_namespace = pd.read_csv(inputpath + "/id_namespace.tsv", sep="\t")
        id_namespace = id_namespace.fillna("")
        for i in id_namespace.index:
            yield C2M2.id_namespace(
                id=id_namespace.at[i,"id"],
                abbreviation=id_namespace.at[i,"abbreviation"],
                name=id_namespace.at[i,"name"],
                description=id_namespace.at[i,"description"],
              )

# In[4]:
def yield_dcc():
    yield C2M2.dcc(
        id="cfde_registry_dcc:idg",
        dcc_name="Illuminating the Druggable Genome",
        dcc_abbreviation="IDG",
        dcc_description="The goal of IDG is to improve our understanding of understudied proteins from the three most commonly drug-targeted protein families: G-protein coupled receptors, ion channels, and protein kinases.",
        contact_email="JJYang@salud.unm.edu",
        contact_name="Jeremy Yang",
        dcc_url="https://www.druggablegenome.net/",
        project_id_namespace=namespace,
        project_local_id="IDG",
    )

# In[5]:
def yield_project():
    for inputpath in glob.glob(indir + "data_*"):
        project = pd.read_csv(inputpath + "/project.tsv", sep="\t")
        project = project.fillna("")
        for i in project.index:
            yield C2M2.project(
                id_namespace=project.at[i, "id_namespace"],
                local_id=project.at[i, "local_id"],
                persistent_id=project.at[i, "persistent_id"],
                creation_time=project.at[i, "creation_time"],
                abbreviation=project.at[i, "abbreviation"],
                name=project.at[i, "name"],
                description=project.at[i, "description"],
            )
            if not project.at[i, "local_id"] == "IDG":
                yield C2M2.project_in_project(
                    parent_project_id_namespace=namespace,
                    parent_project_local_id="IDG",
                    child_project_id_namespace=project.at[i, "id_namespace"],
                    child_project_local_id=project.at[i, "local_id"]
                )

# In[6]:
def yield_file():
    for inputpath in glob.glob(indir + "data_*"):
        file = pd.read_csv(inputpath + "/file.tsv", sep="\t")
        for i in file.index:
            local_id=file.at[i, "local_id"]
            yield C2M2.file(
                id_namespace=file.at[i, "id_namespace"],
                local_id=local_id ,
                project_id_namespace=file.at[i, "project_id_namespace"],
                project_local_id=file.at[i, "project_local_id"],
                persistent_id=file.at[i, "persistent_id"],
                creation_time=file.at[i, "creation_time"],
                size_in_bytes=int(file.at[i, "size_in_bytes"]) if not not file.at[i, "size_in_bytes"] == "" and not pd.isna(file.at[i, "size_in_bytes"]) else "",
                uncompressed_size_in_bytes=int(file.at[i, "uncompressed_size_in_bytes"]) if not file.at[i, "uncompressed_size_in_bytes"] == "" and not pd.isna(file.at[i, "uncompressed_size_in_bytes"]) else "",
                sha256=file.at[i, "sha256"],
                md5=file.at[i, "md5"],
                filename=file.at[i, "filename"],
                file_format=file.at[i, "file_format"] if not pd.isna(file.at[i, "file_format"]) else "",
                data_type=file.at[i, "data_type"] if not pd.isna(file.at[i, "data_type"]) else "",
                assay_type=file.at[i, "assay_type"] if not pd.isna(file.at[i, "assay_type"]) else "",
                analysis_type=file.at[i, "analysis_type"] if not pd.isna(file.at[i, "analysis_type"]) else "",
                mime_type=file.at[i, "mime_type"],
                compression_format=file.at[i, "compression_format"] if local_id.endswith(".gz") else ""
            )

# In[7]:
def yield_file_in_collection():
    for inputpath in glob.glob(indir + "/data_*"):
        file = pd.read_csv(inputpath + "/file_in_collection.tsv", sep="\t")
        f = pd.read_csv(inputpath + "/file.tsv", sep="\t", index_col=1)
        for i in file.index:
            file_local_id = file.at[i, "file_local_id"]
            yield C2M2.file_in_collection(
                file_id_namespace=file.at[i, "file_id_namespace"],
                file_local_id=file_local_id,
                collection_id_namespace=file.at[i, "collection_id_namespace"],
                collection_local_id=file.at[i, "collection_local_id"],
            )

# In[8]:
def yield_collection_compound():
    for inputpath in glob.glob(indir + "/data_*"):
        file = pd.read_csv(inputpath + "/collection_compound.tsv", sep="\t")
        for i in file.index:
            yield C2M2.collection_compound(
                collection_id_namespace=file.at[i, "collection_id_namespace"],
                collection_local_id=file.at[i, "collection_local_id"],
                compound=file.at[i, "compound"],
            )

# In[9]:
def yield_collection_defined_by_project():
    for inputpath in glob.glob(indir + "/data_*"):
        file = pd.read_csv(inputpath + "/collection_defined_by_project.tsv", sep="\t")
        for i in file.index:
            yield C2M2.collection_defined_by_project(
                collection_id_namespace=file.at[i, "collection_id_namespace"],
                collection_local_id=file.at[i, "collection_local_id"],
                project_id_namespace=file.at[i, "project_id_namespace"],
                project_local_id=file.at[i, "project_local_id"],
            )

# In[10]:
def yield_collection_disease():
    for inputpath in glob.glob(indir + "/data_*"):
        file = pd.read_csv(inputpath + "/collection_disease.tsv", sep="\t")
        for i in file.index:
            yield C2M2.collection_disease(
                collection_id_namespace=file.at[i, "collection_id_namespace"],
                collection_local_id=file.at[i, "collection_local_id"],
                disease=file.at[i, "disease"],
            )

# In[11]:
def yield_collection_gene():
    for inputpath in glob.glob(indir + "/data_*"):
        file = pd.read_csv(inputpath + "/collection_gene.tsv", sep="\t")
        for i in file.index:
            yield C2M2.collection_gene(
                collection_id_namespace=file.at[i, "collection_id_namespace"],
                collection_local_id=file.at[i, "collection_local_id"],
                gene=file.at[i, "gene"],
            )

# In[12]:
def yield_collection_taxonomy():
    for inputpath in glob.glob(indir + "/data_*"):
        file = pd.read_csv(inputpath + "/collection_taxonomy.tsv", sep="\t")
        for i in file.index:
            yield C2M2.collection_taxonomy(
                collection_id_namespace=file.at[i, "collection_id_namespace"],
                collection_local_id=file.at[i, "collection_local_id"],
                taxon=file.at[i, "taxon"],
            )

# In[13]:
def yield_collection():
    for inputpath in glob.glob(indir + "/data_*"):
        file = pd.read_csv(inputpath + "/collection.tsv", sep="\t")
        for i in file.index:
            persistent_id = file.at[i, "persistent_id"]
            yield C2M2.collection(
                id_namespace=file.at[i, "id_namespace"],
                local_id=file.at[i, "local_id"],
                persistent_id=file.at[i, "persistent_id"].replace("_associations_associations", "_associations"),
                creation_time=file.at[i, "creation_time"] if not pd.isna(file.at[i, "creation_time"]) else "",
                abbreviation=file.at[i, "abbreviation"] if not pd.isna(file.at[i, "abbreviation"]) else "",
                name=file.at[i, "name"] if not pd.isna(file.at[i, "name"]) else "",
                description=file.at[i, "description"] if not pd.isna(file.at[i, "description"]) else "",
                has_time_series_data=file.at[i, "has_time_series_data"] if not pd.isna(file.at[i, "has_time_series_data"]) else "",
            )

# In[14]:
def convert_idg_to_c2m2():
   for i in yield_id_namespace():
       yield i
   for i in yield_dcc():
       yield i
   for i in yield_project():
       yield i
   for i in yield_file():
       yield i
   for i in yield_file_in_collection():
       yield i
   for i in yield_collection_compound():
       yield i
   for i in yield_collection_defined_by_project():
       yield i
   for i in yield_collection_disease():
       yield i
   for i in yield_collection_gene():
       yield i
   for i in yield_collection_taxonomy():
       yield i
   for i in yield_collection():
       yield i

# In[15]:
outdir = f"{indir}/IDG_merged"
pkg = create_datapackage("C2M2", convert_idg_to_c2m2(), outdir, schema_file=f"{indir}/C2M2_datapackage.json")

# In[16]:
get_ipython().system(f"python3 preparation_scripts/v12.py {outdir}")

# In[17]:
get_ipython().system(f"cp autogenerated_C2M2_term_tables/* {outdir}")

# In[18]:
validate_datapackage(pkg)

