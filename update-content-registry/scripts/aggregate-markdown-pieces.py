#! /usr/bin/env python
"""
Aggregate a bunch of individual markdown chunks into one large list of
JSON dictionaries, combining for individual IDs.
"""
import argparse
import sys
import os
import json
from collections import defaultdict


# utility function: walk all directories on the comand line
def walk_em_all(dirlist):
    for dirname in dirlist:
        for x in os.walk(dirname):
            yield x

def main():
    p = argparse.ArgumentParser()
    p.add_argument('pieces_dirs', nargs="+")
    p.add_argument('--output-json', '-o', required=True)
    args = p.parse_args()

    n_skipped = 0
    n_loaded = 0

    # all command-line args must be directories.
    for pieces_dir in args.pieces_dirs:
        if not os.path.isdir(pieces_dir):
            print(f"ERROR: '{pieces_dir}' is not a directory.", file=sys.stderr)
            sys.exit(-1)

    # gather chunks across all input directories.
    chunks_by_cv_id = defaultdict(list)
    for (dirpath, dirnames, filenames) in walk_em_all(args.pieces_dirs):
        for filename in filenames:
            if not filename.endswith('.json'):
                n_skipped += 1
                #print(f"skipping {filename} - does not end with .json")
                continue

            filename = os.path.join(dirpath, filename)
            #print(f"Loading from {filename}", file=sys.stderr)

            with open(filename, 'rt') as fp:
                d = json.load(fp)
                assert 'id' in d.keys()
                assert 'resource_markdown' in d.keys()

                # store markdown chunks by cv_id...
                cv_id = d['id']

                # ...and track the original filename/path they're saved
                # under, for later sorting.
                chunks_by_cv_id[cv_id].append((filename, d))

            n_loaded += 1

    #
    # now, merge 'resource_markdown' entries by (sorted) filename.
    #

    chunks = []

    # here, we sort by cv_id, which is probably unnecessary.
    cv_id_list = sorted(chunks_by_cv_id)
    for cv_id in cv_id_list:

        # under each cv_id, we have a list of (filename, dict)
        # where the dict contains 'id' and 'resource_markdown'
        # and the filename is where it was loaded from.
        #
        # sorting the values here is what determines the aggregation
        # order.

        vv = sorted(chunks_by_cv_id[cv_id]) #  sort by filename
        combined_md = []
        for _, d in vv:
            assert d['id'] == cv_id
            combined_md.append(d['resource_markdown'])

        # aggregate!
        combined_md = "\n".join(combined_md) + "\n"

        # save aggregated chunks under a new dictionary
        chunks.append(dict(id=cv_id, resource_markdown=combined_md))

    # for upload to deriva, we want a list of JSON dictionaries in a single
    # file:
    with open(args.output_json, 'wt') as fp:
        json.dump(chunks, fp)

    print(f"Loaded {n_loaded} chunks total.", file=sys.stderr)
    print(F"Skipped {n_skipped} files for not ending in .json.", file=sys.stderr)
    print(f"Wrote {len(chunks)} chunks to {args.output_json}", file=sys.stderr)


if __name__ == '__main__':
    sys.exit(main())
