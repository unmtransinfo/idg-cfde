from idgapireader import PharosAPIReader, ParseJasonToMD
import pandas as pd
import json


def get_disease_protein_names(ifile=None, d_type="protein"):
    """
    read the input file and get uniprot_id or disease name.
    """
    df = pd.read_csv(ifile)
    if d_type == "protein":
        vals = df['UniProt'].to_numpy()
    elif d_type == "disease":
        vals = df['Associated Disease'].to_numpy()
    return vals


def generate_disease_markdown_file(ifile=None, ofile=None):
    """
    This function reads the information from pharos API and creates a markdown file for the disease
    """
    disease_list = []
    d_count = 0

    print("get all disease names from the csv file")
    diseases = get_disease_protein_names(ifile=ifile, d_type="disease")

    # get details of a disease using API
    ph_api = PharosAPIReader()
    mdf = ParseJasonToMD(ptype="disease")

    # get details for each disease
    print("fetch disease information from Pharos server")
    for d_name in diseases:
        d_count += 1
        res = ph_api.fetch_data_using_disease_name(disease=d_name)

        # convert json to markdown format
        if res is None:
            print("Pharos API returned no data for disease: {0}".format(d_name))
            continue
        md_data = mdf.convert_json_to_md(json_data=res, pval=d_name)
        if md_data is not None:
            disease_list.append(md_data)

        if d_count % 1000 == 0:
            print("Out of {0} diseases {1} have DOID".format(d_count, len(disease_list)))

    # save data in a json file
    print("Out of {0} diseases {1} have DOID".format(d_count, len(disease_list)))
    with open(ofile, "w") as fo:
        json.dump(disease_list, fo, indent=2, separators=(',', ':'))


def generate_protein_markdown_file(ifile=None, ofile=None):
    """
    This function reads the information from pharos API and creates a markdown file for the protein
    """
    protein_list = []
    p_count = 0

    print("get all uniprot ids from the csv file")
    proteins = get_disease_protein_names(ifile=ifile, d_type="protein")

    # get details of a disease using API
    ph_api = PharosAPIReader()
    mdf = ParseJasonToMD(ptype="protein")

    # get details for each disease
    print("fetch protein information from Pharos server")
    for pid in proteins:
        p_count += 1
        res = ph_api.fetch_data_using_uniprot_id(uniprot_id=pid)

        # convert json to markdown format
        if res is None:
            print("Pharos API returned no data for protein: {0}".format(pid))
            continue
        md_data = mdf.convert_json_to_md(json_data=res, pval=pid)
        if md_data is not None:
            protein_list.append(md_data)

        if p_count % 1000 == 0:
            print("Out of {0} proteins {1} have uniprot_id".format(p_count, len(protein_list)))

    # save data in a json file
    print("Out of {0} proteins {1} have uniprot_id".format(p_count, len(protein_list)))
    with open(ofile, "w") as fo:
        json.dump(protein_list, fo, indent=2, separators=(',', ':'))


if __name__ == "__main__":
    # input output files
    disease_ifile = "data/diseases.csv"  # download from https://pharos.nih.gov/diseases
    protein_ifile = "data/proteins.csv"  # download from https://pharos.nih.gov/targets
    disease_md_ofile = "data/disease_markdown.json"
    protein_md_ofile = "data/protein_markdown.json"

    # create markdown file for protein
    generate_protein_markdown_file(ifile=protein_ifile, ofile=protein_md_ofile)

    # create markdown file for disease
    generate_disease_markdown_file(ifile=disease_ifile, ofile=disease_md_ofile)
