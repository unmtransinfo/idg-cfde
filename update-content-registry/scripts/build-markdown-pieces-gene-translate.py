#! /usr/bin/env python
import argparse
import sys
import csv
import json
import urllib.parse
import os.path
from collections import defaultdict

import cfde_common


def main():
    p = argparse.ArgumentParser()
    p.add_argument('term')
    p.add_argument('id_list')
    p.add_argument('alias_file')
    p.add_argument('--output-dir', '-o',
                   help="output directory, defaults to 'output_pieces_{termtype}")
    p.add_argument('--widget-name', default="widget",
                   help="widget name, used to set the output filename(s)")
    args = p.parse_args()

    # validate term
    term = args.term
    if term not in cfde_common.REF_FILES:
        print(f"ERROR: unknown term type '{term}'", file=sys.stderr)
        sys.exit(-1)

    print(f"Running with term: {term}", file=sys.stderr)

    # output dir default
    output_dir = args.output_dir
    if output_dir is None:
        output_dir = f"output_pieces_{term}"
    print(f"Using output dir {output_dir} for pieces.")

    if not os.path.exists(output_dir):
        os.mkdir(output_dir)

    ref_file = cfde_common.REF_FILES.get(term)
    if ref_file is None:
        print(f"ERROR: no ref file for term. Dying terribly.", file=sys.stderr)
        sys.exit(-1)

    # load in ref file; ID is first column
    ref_id_list = set()
    with open(ref_file, 'r', newline='') as fp:
        r = csv.DictReader(fp, delimiter='\t')
        for row in r:
            ref_id = row['id']
            ref_id_list.add(ref_id)

    print(f"Loaded {len(ref_id_list)} reference IDs from {ref_file}",
          file=sys.stderr)

    # load in alias file.
    alias_info = {}
    with open(args.alias_file, 'r', newline='') as fp:
        r = csv.DictReader(fp, delimiter='\t')
        def isnull(value):
            if not value or value == 'NA':
                return True
            return False

        for row in r:
            entrez_id = row['ENTREZID']
            assert not isnull(entrez_id)

            ensembl_id = row['ENSEMBL']
            if not isnull(ensembl_id):
                mim_id = row['MIM']

                hgnc_id = None
                hgnc_val = row['HGNC'].split('|')[0]
                if hgnc_val:
                    hgnc_id = int(hgnc_val)

                hgnc_symbol = row['SYMBOL']
                hgnc_gene_name = row['GENENAME']

                refseq_ids = row['REFSEQ']
                if not isnull(refseq_ids):
                    refseq_ids = refseq_ids.split('|')
                else:
                    refseq_ids = []
                    
                uniprot_ids = row['UNIPROT']
                if not isnull(uniprot_ids):
                    uniprot_ids = uniprot_ids.split('|')
                else:
                    uniprot_ids = []

                hgncIDString = hgncSymbolString = hgncGeneNameString = ""
                if hgnc_id:
                    hgncIDString = f"[{hgnc_id}](https://www.genenames.org/data/gene-symbol-report/#!/hgnc_id/HGNC:{hgnc_id})";

                    hgncSymbolString = f"[{hgnc_symbol}](https://www.genenames.org/data/gene-symbol-report/#!/hgnc_id/HGNC:{hgnc_symbol})";

                    hgncGeneNameString = f"[{hgnc_gene_name}](https://www.genenames.org/data/gene-symbol-report/#!/hgnc_id/HGNC:{hgnc_id})";

                refseq_str = ""
                if refseq_ids:
                    x = []
                    for refseq_id in refseq_ids:
                        x.append(f"[{refseq_id}](https://view.ncbi.nlm.nih.gov/protein/{refseq_id})")
                    refseq_str = ", ".join(x)

                uniprot_str = ""
                if uniprot_ids:
                    x = []
                    for uniprot_id in uniprot_ids:
                        x.append(f"[{uniprot_id}](https://www.uniprot.org/uniprot/{uniprot_id})")
                    uniprot_str = ", ".join(x)

                alias_md = f""":span:Links to external resources for {ensembl_id}:/span:{{.caption-match style=\"font-size:24px;font-weight:bold\"}}\n\n| Resource | Links |\n| --- | --- |\n| Ensembl | [{ensembl_id}](http://www.ensembl.org/id/{ensembl_id}) |\n| NCBI Gene | [{entrez_id}](https://www.ncbi.nlm.nih.gov/gene/{entrez_id}) |\n | Human Gene Nomenclature (HGNC) | [{hgnc_id}](https://www.genenames.org/data/gene-symbol-report/#!/hgnc_id/HGNC:{hgnc_id})|\n  | OMIM | [{mim_id}](https://omim.org/entry/{mim_id}) |\n| RefSeq | {refseq_str} |\n| UniProtKB | {uniprot_str} |\n| CFDE Gene Partnership Appyter | [{ensembl_id}](https://appyters.maayanlab.cloud/CFDE-Gene-Partnership/#?args.gene={ensembl_id}&submit)|\n|\n"""

                alias_info[ensembl_id] = alias_md

    # load in id list
    id_list = set()
    with open(args.id_list, 'rt') as fp:
        for line in fp:
            line = line.strip()
            if line:
                if line not in ref_id_list:
                    print(f"ERROR: requested input id {line} not found in ref_id_list", file=sys.stderr)
                    sys.exit(-1)

                id_list.add(line)

    print(f"Loaded {len(id_list)} IDs from {args.id_list}",
          file=sys.stderr)

    template_name = 'alias_tables'
    for cv_id in sorted(id_list):
        resource_markdown = alias_info.get(cv_id)
        if resource_markdown:
            # write out JSON pieces for aggregation & upload
            cfde_common.write_output_pieces(output_dir, args.widget_name,
                                            cv_id, resource_markdown)
        else:
            print(f"WARNING: missing markdown for identifier {cv_id}")


if __name__ == '__main__':
    sys.exit(main())
