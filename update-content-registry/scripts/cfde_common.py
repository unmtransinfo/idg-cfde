"""
Utility code common to content registry foo.
"""
import os.path
import urllib.parse
import json


REF_FILES = {
    'anatomy': 'data/validate/anatomy.tsv',
    'compound': 'data/validate/compound.tsv',
    'disease': 'data/validate/disease.tsv',
    'gene': 'data/validate/ensembl_genes.tsv',
    }


def write_output_pieces(output_dir, widget_name, cv_id, md, *, verbose=False):
    #if md is None:
    #    print(f"NO markdown for cv_id {cv_id}")
    #    return
    #else:
    #    print(f"GOT markdown for cv_id {cv_id}")

    output_filename = f"{widget_name}_{urllib.parse.quote(cv_id)}.json"
    output_filename = os.path.join(output_dir, output_filename)

    with open(output_filename, 'wt') as fp:
        d = dict(id=cv_id, resource_markdown=md)
        json.dump(d, fp)

    if verbose:
        print(f"Wrote JSON to {output_filename}")

    # write markdown - it's not used anywhere, but is available for inspection.
    output_filename = f"{widget_name}_{urllib.parse.quote(cv_id)}.md"
    output_filename = os.path.join(output_dir, output_filename)

    with open(output_filename, 'wt') as fp:
        fp.write(md)

    if verbose:
        print(f"Wrote markdown to {output_filename}")
