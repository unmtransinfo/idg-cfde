import requests
import sys


# ********************************************** #
# *** Read Pharos API using GraphQL          *** #
# ********************************************** #
class PharosAPIReader:
    def __init__(self):
        self.headers = {'content-type': 'application/json'}
        self.resource_url = 'https://pharos-api.ncats.io/graphql'

    def fetch_all_disease_name(self):
        """
        This function accesses Pharos GraphQL API to fetch all disease names.
        :return:
        a list of diseases
        """

        doid_disease = {}
        json_data = {
            'query': 'query diseaseDetails($doid: String){\n  diseaseOntology(doid: $doid) {\n    name\n  doid\n}\n}',
        }

        # fetch data from API
        response = None
        try:
            response = requests.post(self.resource_url, headers=self.headers, json=json_data)
        except requests.exceptions.RequestException as e:
            print("something went wrong in fetch_all_disease_name", e)

        # parse json data
        if response is not None:
            try:
                jdata = response.json()
                for v in jdata["data"]["diseaseOntology"]:
                    doid_disease[v["doid"]] = v["name"]
            except requests.exceptions.JSONDecodeError as e:
                print("something went wrong in fetch_all_disease_name", e)
                doid_disease = None
        else:
            doid_disease = None

        # return a list of disease
        return doid_disease

    def fetch_data_using_disease_name(self, disease=None):
        """
        This function accesses Pharos GraphQL API to fetch data for the given disease.

        :return:
         data in json format
        """
        json_data = {
            'query': 'query diseaseDetails{\n  disease(name:"' + disease + '"){\n    mondoID\n    name\n    '
                                                                           'mondoDescription\n    '
                                                                           'uniprotDescription\n    doDescription\n   '
                                                                           ' targetCounts {\n      name\n      '
                                                                           'value\n    }\n    mondoEquivalents {\n    '
                                                                           '  id\n      name\n    }\n  }\n}',
        }

        # fetch data from API
        response = None
        try:
            response = requests.post(self.resource_url, headers=self.headers, json=json_data)
        except requests.exceptions.RequestException as e:
            print("something went wrong in fetch_data_using_disease_name", e)
            response = None

        # get json from response
        returned_disease_data = None
        if response is not None:
            try:
                returned_disease_data = response.json()
            except requests.exceptions.JSONDecodeError as e:
                print("something went wrong in fetch_data_using_disease_name", e)
                returned_disease_data = None

        return returned_disease_data

    def fetch_data_using_uniprot_id(self, uniprot_id=None):
        """
        This function accesses Pharos GraphQL API fetch data for the given protein uniprot_id.

        :return:
         data in json format
        """
        json_data = {
            'query': 'query targetDetails{\n  target(q:{sym:"' + uniprot_id + '"}) {\n    name\n    tdl\n    fam\n    '
                                                                              'sym\n    uniprot\n    props(name: '
                                                                              '"UniProt Function") {\n      value\n   '
                                                                              ' }\n    description\n    synonyms {\n  '
                                                                              '    name\n      value\n    }\n        '
                                                                              'harmonizome {\n      summary {\n       '
                                                                              ' name\n        value\n      }\n        '
                                                                              '}\n    xrefs(source: "Ensembl") {\n    '
                                                                              '  name\n    }\n  }\n}',
        }

        # fetch data from API
        response = None
        try:
            response = requests.post(self.resource_url, headers=self.headers, json=json_data)
        except requests.exceptions.RequestException as e:
            print("something went wrong in fetch_data_using_uniprot_id", e)
            response = None

        # get protein data
        returned_protein_data = None
        if response is not None:
            try:
                returned_protein_data = response.json()
            except requests.exceptions.JSONDecodeError as e:
                print("something went wrong in fetch_data_using_uniprot_id", e)
                returned_protein_data = None

        return returned_protein_data


# ********************************************** #
# *** convert json to markdown format        *** #
# ********************************************** #
def convert_json_to_md_disease(jdata, d_name):
    """
    This function converts json to MD format for disease
    :return:
    data in MD format
    """
    doid_md_format = {}
    ph_url = "https://pharos.nih.gov/diseases/"
    do_url = "https://disease-ontology.org/?id="

    # populate md_str
    md_str = "\n# Disease Summary\n\n## Name\n" + str(d_name) + "\n\n## Associated Targets\n|||\n|-|-|"

    # associate targets
    try:
        assoc_targets = jdata['data']['disease']['targetCounts']
    except:
        assoc_targets = None
    if assoc_targets is not None:
        for targets in assoc_targets:
            md_str = md_str + "\n|" + str(targets['name']) + "|" + str(targets['value']) + "|"

    # descriptions
    try:
        md_str = md_str + "\n\n## Mondo Description\n" + str(jdata['data']['disease']['mondoDescription'])
    except:
        md_str = md_str + "\n\n## Mondo Description\n"
    try:
        md_str = md_str + "\n\n## Disease Ontology Description\n" + str(jdata['data']['disease']['doDescription'])
    except:
        md_str = md_str + "\n\n## Disease Ontology Description\n"
    try:
        md_str = md_str + "\n\n## Uniprot Description\n" + str(jdata['data']['disease']['uniprotDescription'])
    except:
        md_str = md_str + "\n\n## Uniprot Description\n"

    # Mondo Term and Equivalent IDs
    doid = ''
    md_str = md_str + "\n\n## Mondo Term and Equivalent IDs"
    try:
        md_str = md_str + "\n- " + str(jdata['data']['disease']['mondoID'])
    except:
        md_str = md_str

    try:
        mondo_equivalents = jdata['data']['disease']['mondoEquivalents']
    except:
        mondo_equivalents = None
    if mondo_equivalents is not None:
        for eqv in mondo_equivalents:
            if eqv['name'] is not None:
                md_str = md_str + "\n- " + str(eqv['id']) + ": " + str(eqv['name'])
            else:
                md_str = md_str + "\n- " + str(eqv['id']) + ": "
            # get doid
            if 'DOID:' in str(eqv['id']):
                doid = str(eqv['id'])

    # URLs
    md_str = md_str + "\n\n## URLs"
    d_urls = [ph_url + doid, do_url + doid]
    md_str = md_str + "\n- Pharos URL: [" + str(d_urls[0]) + "](" + str(d_urls[0]) + ")"
    md_str = md_str + "\n- DiseaseOntology URL: [" + str(d_urls[1]) + "](" + str(d_urls[1]) + ")"
    md_str = md_str + "\n\n"

    # save as dict
    if doid == '':
        return None
    else:
        doid_md_format["id"] = doid
        doid_md_format["resource_markdown"] = md_str

    return doid_md_format


def convert_json_to_md_protein(jdata, uniprot_id):
    """
    This function converts json to MD format for protein
    :return:
    data in MD format
    """
    pid_md_format = {}
    uniprot_url = "https://www.uniprot.org/uniprotkb/"
    gene_url = "https://www.genenames.org/data/gene-symbol-report/#!/symbol/"
    ph_url = "https://pharos.nih.gov/targets/"

    # populate md_str
    md_str = "\n# Protein Summary\n\n"
    md_str = md_str + "## Name\n" + str(jdata['data']['target']['name']) + "\n\n## Description"
    for desc in jdata['data']['target']['props']:
        if desc['value'] is not None:
            md_str = md_str + "\n" + str(desc['value'])
    if jdata['data']['target']['description'] is not None:
        md_str = md_str + str(jdata['data']['target']['description'])

    # Uniprot Accession IDs including secondary
    secondary_acc_ids = fetch_secondary_accession_id(uniprot_id=uniprot_id)
    md_str = md_str + "\n\n## Uniprot Accession IDs\n"
    if jdata['data']['target']['uniprot'] is not None:
        md_str = md_str + "[" + str(jdata['data']['target']['uniprot']) + "](" + uniprot_url + \
                 str(jdata['data']['target']['uniprot']) + "/entry) "
    if secondary_acc_ids is not None:
        for u_id in secondary_acc_ids:
            md_str = md_str + " [" + str(u_id) + "](" + uniprot_url + str(u_id) + "/entry) "

    # Gene Name
    md_str = md_str + "\n\n## Gene Name\n"
    if jdata['data']['target']['sym'] is not None:
        md_str = md_str + "[" + str(jdata['data']['target']['sym']) + "](" + gene_url + \
                 str(jdata['data']['target']['sym']) + ") "

    # Ensembl ID
    md_str = md_str + "\n\n## Ensembl ID\n"
    for ensmbl in jdata['data']['target']['xrefs']:
        if ensmbl['name'] is not None:
            md_str = md_str + str(ensmbl['name']) + "  "

    # Symbol
    md_str = md_str + "\n\n## Symbol\n"
    for symbl in jdata['data']['target']['synonyms']:
        if symbl['name'] == "symbol":
            md_str = md_str + symbl['value'] + "  "

    # Knowledge Table
    md_str = md_str + "\n\n## Knowledge Table\n|Most Knowledge About|Knowledge Value (0 to 1 scale)|\n|-|-|\n"
    for kdata in jdata['data']['target']['harmonizome']['summary']:
        md_str = md_str + "|" + str(kdata['name']) + "|" + str(kdata['value']) + "|\n"

    # URLs
    md_str = md_str + "\n\n## URLs"
    p_urls = [ph_url + uniprot_id, uniprot_url + uniprot_id + "/entry"]
    md_str = md_str + "\n- Pharos URL: [" + str(p_urls[0]) + "](" + str(p_urls[0]) + ")"
    md_str = md_str + "\n- UniProtKB URL: [" + str(p_urls[1]) + "](" + str(p_urls[1]) + ")"
    md_str = md_str + "\n\n"

    # save as dict
    pid_md_format["id"] = uniprot_id
    pid_md_format["resource_markdown"] = md_str

    return pid_md_format


def fetch_secondary_accession_id(uniprot_id=None):
    """
    For the given uniprot_id, fetch the secondary uniprot accession ids using Unitprot API.
    """
    headers = {"Accept": "application/json"}
    resource_url = "https://www.ebi.ac.uk/proteins/api/proteins?offset=0&size=100&accession="
    if uniprot_id is None:
        print("uniprot_id was not provided")
        exit(0)
    else:
        request_url = resource_url + uniprot_id
        res = requests.get(request_url, headers=headers)

        # check response and fetch secondary accession ids
        if not res.ok:
            res.raise_for_status()
            sys.exit()
        else:
            jdata = res.json()
            try:
                return jdata[0]["secondaryAccession"]
            except:
                return None


class ParseJasonToMD:
    def __init__(self, ptype="disease"):
        self.ptype = ptype

    def convert_json_to_md(self, json_data=None, pval=None):
        """
        This function converts json to MD format
        :return:
        data in MD format
        """

        if self.ptype == "disease":
            return convert_json_to_md_disease(json_data, pval)
        elif self.ptype == "protein":
            return convert_json_to_md_protein(json_data, pval)
