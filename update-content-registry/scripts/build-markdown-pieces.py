#! /usr/bin/env python
import argparse
import sys
import csv
import json
import urllib.parse
import os.path

import cfde_common


TEMPLATES = set([('gene', 'expression_widget'),
                 ('gene', 'transcripts_widget'),
                 ('gene', 'alias_tables'),
                 ('anatomy', 'expression_widget')
                 ])


def main():
    p = argparse.ArgumentParser()
    p.add_argument('term')
    p.add_argument('id_list')
    p.add_argument('--widget-name', default="widget",
                   help="widget name, used to set the output filename(s)")
    p.add_argument('--output-dir', '-o')
    args = p.parse_args()

    # validate term
    term = args.term
    if term not in cfde_common.REF_FILES:
        print(f"ERROR: unknown term type '{term}'", file=sys.stderr)
        sys.exit(-1)

    # validate template_name
    tup = (term, args.widget_name)
    if tup not in TEMPLATES:
        print(f"ERROR: unknown term/template pair {tup}", file=sys.stderr)
        sys.exit(-1)
    template_name = args.widget_name

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

    for cv_id in sorted(id_list):
        resource_markdown = None
        if term =='gene':
            if template_name == 'expression_widget':
                resource_markdown = f"::: iframe [**Expression data (via GTEx API):**](https://mii.podvis.org/cfde-ge1/#/gene_tissues?gencode_id={cv_id}&width=1200&height=450&numTopTissues=10){{width=\"1200\" height=\"450\" style=\"border: 1px solid black;\" caption-style=\"font-size: 24px;\" caption-link=\"https://gtexportal.org/home/api-docs/index.html#/expression\" caption-target=\"_blank\"}} \n:::\n"
            elif template_name == 'transcripts_widget':
                resource_markdown = f"::: iframe [**Transcript list (via GTEx API):**](https://mii.podvis.org/cfde-ge1/#/gene_transcripts?gencode_id={cv_id}&width=1200&height=300){{width=\"1200\" height=\"300\" style=\"border: 1px solid black;\" caption-style=\"font-size: 24px;\" caption-link=\"https://gtexportal.org/home/api-docs/index.html#/reference\" caption-target=\"_blank\"}} \n:::\n";
            elif template_name == 'alias_tables':
                assert 0
            else:
                assert 0
        elif term =='anatomy':
            if template_name == 'expression_widget':
                cv_id_encoded = urllib.parse.quote(cv_id)
                resource_markdown = f"::: iframe [**Expression data from GTEx:**](https://mii.podvis.org/cfde-ge1/#/anatomy?uberon_ids={cv_id_encoded}&width=1400&height=550&numTopGenes=25){{width=\"1400\" height=\"550\" style=\"border: 1px solid black;\" caption-style=\"font-size: 24px;\" caption-link=\"https://gtexportal.org/home/api-docs/index.html#/expression\" caption-target=\"_blank\"}} \n:::\n"
            else:
                assert 0
        elif term == 'compound':
            assert 0
        elif term == 'disease':
            assert 0

        assert resource_markdown is not None

        # write out JSON pieces for aggregation & upload
        cfde_common.write_output_pieces(output_dir, args.widget_name,
                                        cv_id, resource_markdown)


if __name__ == '__main__':
    sys.exit(main())
