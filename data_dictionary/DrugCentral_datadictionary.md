| Table Name | Column Name | Data Type | Column_Description |
| --- | --- | --- | --- |
| act_table_full | act_id | int4 | Unique id for activity data |
| act_table_full | struct_id | int4 | DrugCentral structure id for drugs |
| act_table_full | target_id | int4 | DrugCentral target id for targets |
| act_table_full | target_name | varchar | Target name |
| act_table_full | target_class | varchar | Protein target class |
| act_table_full | accession | varchar | Unique entry identifier from UniProtKB |
| act_table_full | gene | varchar | Name of the gene encoding the protein from UniProtKB |
| act_table_full | swissprot | varchar | Entry name identifier from UniProtKB |
| act_table_full | act_value | float8 | Bioactivity data extracted from different sources |
| act_table_full | act_unit | varchar | Bioactivity measurement unit type |
| act_table_full | act_type | varchar | Bioactivity measurement type |
| act_table_full | act_comment | varchar | Short description of the bioactivity data, e.g. assay type, measurement, conditions, etc |
| act_table_full | act_source | varchar | Source of the bioactivity data |
| act_table_full | relation | varchar | Mathematical identifier |
| act_table_full | moa | int2 | Mechanism of action of the drug |
| act_table_full | moa_source | varchar | Mechanism of action source |
| act_table_full | act_source_url | varchar | The URL for the source of the bioactivity data |
| act_table_full | moa_source_url | varchar | The URL for the source of the mechanism of action for a drug |
| act_table_full | action_type | varchar | Pharmacological action type |
| act_table_full | first_in_class | int2 | First in class drug annotation |
| act_table_full | tdl | varchar | Target development level, as defined at http://juniper.health.unm.edu/tcrd/ |
| act_table_full | act_ref_id | int4 | Unique identifier of the bioactivity data reference |
| act_table_full | moa_ref_id | int4 | Unique identifier of the reference for the mechanism of action |
| act_table_full | organism | varchar | The species expressing the target |
| action_type | id | serial | Unique identifier of the pharmacological action type |
| action_type | action_type | varchar | Pharmacological action type |
| action_type | description | varchar | Short description of each pharmacological action type |
| action_type | parent_type | varchar | Pharmacological action type of the parent molecule |
| active_ingredient | id | serial | DrugCentral unique identifier for active ingredient entry extracted from DailyMed data |
| active_ingredient | active_moiety_unii | varchar | UNII moiety code of the active substance extracted from DailyMed data |
| active_ingredient | active_moiety_name | varchar | UNII moiety nameof the active substance extracted from DailyMed data |
| active_ingredient | unit | varchar | Measurement unit type |
| active_ingredient | quantity | float8 | The amount of active ingredient |
| active_ingredient | substance_unii | varchar | UNII code of the active substance extracted from DailyMed data |
| active_ingredient | substance_name | varchar | Active substance name extracted from DailyMed data |
| active_ingredient | ndc_product_code | varchar | FDA NDC code of the drug product extracted from DailyMed data |
| active_ingredient | struct_id | int4 | DrugCentral structure id mapped to the active substance |
| active_ingredient | quantity_denom_unit | varchar | Unit type for the quantitiy of the active substance in the drug product (DailyMed) |
| active_ingredient | quantity_denom_value | float8 | Quantitiy value of the active substance in the drug product (DailyMed) |
| approval | id | serial | Unique identifier for the approval entry |
| approval | struct_id | int4 | DrugCentral structure id for drug |
| approval | approval | date | Approval date of the drug |
| approval | type | varchar | Approval agency |
| approval | applicant | varchar | The name of the applicant |
| approval | orphan | bool | Orphan status |
| approval_type | id | serial | Unique DrugCentral identifier for the indexed approval agencies |
| approval_type | descr | varchar | The name of the approval agengies indexed in DrugCentral |
| atc | id | serial | DrugCentral identifier for the ATC codes |
| atc | code | bpchar | The ATC code of the specific drug |
| atc | chemical_substance | varchar | The drug name |
| atc | l1_code | bpchar | The ATC level 1 of the drug |
| atc | l1_name | varchar | The corresponding name of the level 1 ATC code of the drug |
| atc | l2_code | bpchar | The ATC level 2 of the drug |
| atc | l2_name | varchar | The corresponding name of the level 2 ATC code of the drug |
| atc | l3_code | bpchar | The ATC level 3 of the drug |
| atc | l3_name | varchar | The corresponding name of the level 3 ATC code of the drug |
| atc | l4_code | bpchar | The ATC level 4 of the drug |
| atc | l4_name | varchar | The corresponding name of the level 4 ATC code of the drug |
| atc | chemical_substance_count | int4 | Number of active substances in the drug product |
| atc_ddd | id | serial | Unique identifier for the entry |
| atc_ddd | atc_code | bpchar | The corresponding ATC code of the drug |
| atc_ddd | ddd | float4 | Defined daily dose |
| atc_ddd | unit_type | varchar | Measurement unit type |
| atc_ddd | route | varchar | Administration route of the drug |
| atc_ddd | comment | varchar | Remarks regarding the drug or administration route |
| atc_ddd | struct_id | int4 | DrugCentral structure id for drug |
| attr_type | id | serial | Unique identifier for the entry |
| attr_type | name | varchar | Attribute name |
| attr_type | type | varchar | Data type of the attribute (e.g., STRING) |
| data_source | src_id | int2 | Unique identifier for each entry |
| data_source | source_name | varchar | Name of the source for bioactivity data |
| dbversion | version | int8 | Version of the database |
| dbversion | dtime | timestamp | Time and date of the version release |
| ddi | id | serial | Unique identifier for each entry of the table |
| ddi | drug_class1 | varchar | Drug-drug interaction class 1 |
| ddi | drug_class2 | varchar | Drug-drug interaction class 2 |
| ddi | ddi_ref_id | int4 | Drug-drug interaction reference |
| ddi | ddi_risk | varchar | Risk assement of the drug-drug interaction |
| ddi | description | varchar | Description of the drug-drug interaction |
| ddi | source_id | varchar | Drug class interactions as DDI sources |
| ddi_risk | id | serial | Unique identifier for each risk class |
| ddi_risk | risk | varchar | Name of the risk classes |
| ddi_risk | ddi_ref_id | int4 | Reference for the DDI risk |
| doid | id | int4 | Unique identifier for each entry of the table |
| doid | label | varchar | Disease name |
| doid | doid | varchar | Disease ontology ID |
| doid | url | varchar | URL link of the disease to the Disease Ontology DB |
| doid_xref | id | serial | Table identifier for each entry |
| doid_xref | doid | varchar | Disease ontology ID |
| doid_xref | source | varchar | Source for the data |
| doid_xref | xref | varchar | External reference id of the medical term |
| drug_class | id | serial | Table identifier for each entry |
| drug_class | name | varchar | Drug class name |
| drug_class | is_group | int2 | 1/0 if group or not |
| drug_class | source | varchar | Source for the data |
| faers | id | serial | Table identifier for each entry |
| faers | struct_id | int4 | DrugCentral structure id for drug |
| faers | meddra_name | varchar | MEDDRA term for the disease |
| faers | meddra_code | int8 | MEDDRA code for the disease |
| faers | level | varchar | Class of the MEDDRA term |
| faers | llr | float8 | Likelihood Ratio based on method described in http://dx.doi.org/10.1198/jasa.2011.ap10243 |
| faers | llr_threshold | float8 | Likelihood Ratio threshold based on method described in http://dx.doi.org/10.1198/jasa.2011.ap10243 |
| faers | drug_ae | int4 | Number of patients taking drug and having adverse event |
| faers | drug_no_ae | int4 | Number of patients taking drug and not having adverse event |
| faers | no_drug_ae | int4 | Number of patients not taking drug and having adverse event |
| faers | no_drug_no_ae | int4 | Number of patients not taking drug and not having adverse event |
| faers_female | id | serial | Table identifier for each entry |
| faers_female | struct_id | int4 | DrugCentral structure id for drug |
| faers_female | meddra_name | varchar | MEDDRA term for the disease |
| faers_female | meddra_code | int8 | MEDDRA code for the disease |
| faers_female | level | varchar | Class of the MEDDRA term |
| faers_female | llr | float8 | Likelihood Ratio based on method described in http://dx.doi.org/10.1198/jasa.2011.ap10243 |
| faers_female | llr_threshold | float8 | Likelihood Ratio threshold based on method described in http://dx.doi.org/10.1198/jasa.2011.ap10243 |
| faers_female | drug_ae | int4 | Number of female patients taking drug and having adverse event |
| faers_female | drug_no_ae | int4 | Number of female patients taking drug and not having adverse event |
| faers_female | no_drug_ae | int4 | Number of female patients not taking drug and having adverse event |
| faers_female | no_drug_no_ae | int4 | Number of female patients not taking drug and not having adverse event |
| faers_ger | id | serial | Table identifier for each entry |
| faers_ger | struct_id | int4 | DrugCentral structure id for drug |
| faers_ger | meddra_name | varchar | MEDDRA term for the disease |
| faers_ger | meddra_code | int8 | MEDDRA code for the disease |
| faers_ger | level | varchar | Class of the MEDDRA term |
| faers_ger | llr | float8 | Likelihood Ratio based on method described in http://dx.doi.org/10.1198/jasa.2011.ap10243 |
| faers_ger | llr_threshold | float8 | Likelihood Ratio threshold based on method described in http://dx.doi.org/10.1198/jasa.2011.ap10243 |
| faers_ger | drug_ae | int4 | Number of patients taking drug and having adverse event |
| faers_ger | drug_no_ae | int4 | Number of patients taking drug and not having adverse event |
| faers_ger | no_drug_ae | int4 | Number of patients not taking drug and having adverse event |
| faers_ger | no_drug_no_ae | int4 | Number of patients not taking drug and not having adverse event |
| faers_male | id | serial | Table identifier for each entry |
| faers_male | struct_id | int4 | DrugCentral structure id for drug |
| faers_male | meddra_name | varchar | MEDDRA term for the disease |
| faers_male | meddra_code | int8 | MEDDRA code for the disease |
| faers_male | level | varchar | Class of the MEDDRA term |
| faers_male | llr | float8 | Likelihood Ratio based on method described in http://dx.doi.org/10.1198/jasa.2011.ap10243 |
| faers_male | llr_threshold | float8 | Likelihood Ratio threshold based on method described in http://dx.doi.org/10.1198/jasa.2011.ap10243 |
| faers_male | drug_ae | int4 | Number of male patients taking drug and having adverse event |
| faers_male | drug_no_ae | int4 | Number of male patients taking drug and not having adverse event |
| faers_male | no_drug_ae | int4 | Number of male patients not taking drug and having adverse event |
| faers_male | no_drug_no_ae | int4 | Number of male patients not taking drug and not having adverse event |
| faers_ped | id | serial | Table identifier for each entry |
| faers_ped | struct_id | int4 | DrugCentral structure id for drug |
| faers_ped | meddra_name | varchar | MEDDRA term for the disease |
| faers_ped | meddra_code | int8 | MEDDRA code for the disease |
| faers_ped | level | varchar | Class of the MEDDRA term |
| faers_ped | llr | float8 | Likelihood Ratio based on method described in http://dx.doi.org/10.1198/jasa.2011.ap10243 |
| faers_ped | llr_threshold | float8 | Likelihood Ratio threshold based on method described in http://dx.doi.org/10.1198/jasa.2011.ap10243 |
| faers_ped | drug_ae | int4 | Number of pediatric patients taking drug and having adverse event |
| faers_ped | drug_no_ae | int4 | Number of pediatric patients taking drug and not having adverse event |
| faers_ped | no_drug_ae | int4 | Number of pediatric patients not taking drug and having adverse event |
| faers_ped | no_drug_no_ae | int4 | Number of pediatric patients not taking drug and not having adverse event |
| humanim | struct_id | int4 | DrugCentral structure id for drug |
| humanim | human | bool | Indicates if it is human drug |
| humanim | animal | bool | Indicates if it is animal drug |
| id_type | id | serial | Unique id for bioactivity databases linked to DrugCentreal |
| id_type | type | varchar | Name of the identifier linked to DrugCentral |
| id_type | description | varchar | Name of the source database |
| id_type | url | varchar | Link url to the webpage of the database |
| identifier | id | serial | Table identifier for each entry |
| identifier | identifier | varchar | Identifier extracted from the linked databases |
| identifier | id_type | varchar | Identifier type |
| identifier | struct_id | int4 | DrugCentral structure id for drug |
| identifier | parent_match | bool | signals parent molecules for the identifier |
| ijc_connect_items | id | varchar | InstantJChem: Item identifier |
| ijc_connect_items | username | varchar | InstantJChem: Name of the user |
| ijc_connect_items | type | varchar | InstantJChem: Type of the items |
| ijc_connect_items | data | text | InstantJChem: Data corresponding to the each item |
| ijc_connect_structures | id | varchar | InstantJChem: Structure identifier |
| ijc_connect_structures | structure_hash | varchar | InstantJChem: Structure hash |
| ijc_connect_structures | structure | text | InstantJChem: Structures |
| inn_stem | id | serial | Table identifier for each entry |
| inn_stem | stem | varchar | STEM |
| inn_stem | definition | varchar | STEM definition |
| inn_stem | national_name | varchar | STEM source |
| inn_stem | length | int2 | STEM length in characters |
| inn_stem | discontinued | bool | STEM status, boolean value |
| label | id | varchar | Label ID |
| label | category | varchar | Label type |
| label | title | varchar | Drug name |
| label | effective_date | date | Label issued date |
| label | assigned_entity | varchar | The entity issuing the label |
| label | pdf_url | varchar | Link url to the label pdf |
| lincs_signature | id | serial | Unique ID for lincs data |
| lincs_signature | struct_id1 | int4 | First drug structure id |
| lincs_signature | struct_id2 | int4 | Second drug structure id |
| lincs_signature | is_parent1 | bool | Signals if the first drug is a parent structure of the DC structure id |
| lincs_signature | is_parent2 | bool | Signals if the second drug is a parent structure of the DC structure id |
| lincs_signature | cell_id | varchar | Id of the cell type |
| lincs_signature | rmsd | float8 | Root-mean-square deviation value |
| lincs_signature | rmsd_norm | float8 | Normalized root-mean-square deviation value |
| lincs_signature | pearson | float8 | Value of the Pearson correlation coefficient |
| lincs_signature | euclid | float8 | Value of the Euclidean distance |
| ob_exclusivity | id | serial | Table identifier for each entry |
| ob_exclusivity | appl_type | bpchar | Patent application type |
| ob_exclusivity | appl_no | bpchar | Application number |
| ob_exclusivity | product_no | bpchar | Product numbers assigend to application number by FDA |
| ob_exclusivity | exclusivity_code | varchar | Exclusivity code |
| ob_exclusivity | exclusivity_date | date | Expiring date for the exclusivity |
| ob_exclusivity_code | code | varchar | Exclusivity code |
| ob_exclusivity_code | description | varchar | Description of the exclusivity code |
| ob_patent | id | serial | Unique ID for OrangeBook (OB) patent entry in DrugCentral |
| ob_patent | appl_type | bpchar | FDA application type associtated with the patent id |
| ob_patent | appl_no | bpchar | FDA application number associtated with the patent id |
| ob_patent | product_no | bpchar | FDA product number |
| ob_patent | patent_no | varchar | Patent number |
| ob_patent | patent_expire_date | date | Patent expiration date |
| ob_patent | drug_substance_flag | bpchar | Signals if the patent is covers the drug substance |
| ob_patent | drug_product_flag | bpchar | Signals if the patent is covers the drug product |
| ob_patent | patent_use_code | varchar | Patent use code |
| ob_patent | delist_flag | bpchar | Signals delisted patents |
| ob_patent_use_code | code | varchar | Patent use code |
| ob_patent_use_code | description | varchar | Patent use code description |
| ob_product | id | serial | Unique ID in DrugCentral for a OB product |
| ob_product | ingredient | varchar | Active substance in OB product |
| ob_product | trade_name | varchar | Commercial name of the OB product |
| ob_product | applicant | varchar | Name of the applying company |
| ob_product | strength | varchar | Concentration of active substance in product |
| ob_product | appl_type | bpchar | FDA application type |
| ob_product | appl_no | bpchar | FDA application number |
| ob_product | te_code | varchar | Therapeutic Equivalence Code |
| ob_product | approval_date | date | Approval date of the drug |
| ob_product | rld | int2 | Reference Listed Drug |
| ob_product | type | varchar | Rx or OTC drug product |
| ob_product | applicant_full_name | varchar | Name of the applying company |
| ob_product | dose_form | varchar | Pharmaceutical formulation of the drug product |
| ob_product | route | varchar | Administration route |
| ob_product | product_no | bpchar | FDA product number |
| omop_relationship | id | serial | DrugCentral unique table identifier |
| omop_relationship | struct_id | int4 | DrugCentral structure id for drug |
| omop_relationship | concept_id | int4 | DrugCentral Identifier of each concept name |
| omop_relationship | relationship_name | varchar | Type of concept name: indication/contraindication |
| omop_relationship | concept_name | varchar | Disease name according to UMLS MetaThesaurus |
| omop_relationship | umls_cui | bpchar | Concept Unique Identifier extracted from UMLS MetaThesaurus |
| omop_relationship | snomed_full_name | varchar | Concept full name from SNOMED CT |
| omop_relationship | cui_semantic_type | bpchar | Concept semantic type from UMLS MetaThesaurus |
| omop_relationship | snomed_conceptid | int8 | Unique identifier of each concept from SNOMED CT |
| parentmol | cd_id | serial | DrugCentral unique table identifier |
| parentmol | name | varchar | Drug name |
| parentmol | cas_reg_no | varchar | Drug CAS number |
| parentmol | inchi | varchar | Drug INCHI |
| parentmol | nostereo_inchi | varchar | Drug INCHI without chirality |
| parentmol | molfile | text | MDL file format of the molecular structure |
| parentmol | molimg | bytea | Encoded image of the molecular structure |
| parentmol | smiles | varchar | SMILES code |
| parentmol | inchikey | bpchar | Drug INCHI key |
| pdb | id | serial | DrugCentral unique table identifier |
| pdb | struct_id | int4 | DrugCentral structure id for drug |
| pdb | pdb | bpchar | PDB identifier of the drug-protein complex |
| pdb | chain_id | varchar | CHAIN ID extracted from PDB |
| pdb | accession | varchar | Entry ID of the target from UniProt |
| pdb | title | varchar | PDB title |
| pdb | pubmed_id | int4 | PUBMED identifier of the reference |
| pdb | exp_method | varchar | Experimental method used to solve the structure |
| pdb | deposition_date | date | PDB deposition date of the solved protein-drug complex |
| pdb | ligand_id | varchar | PDB drug identifier |
| pharma_class | id | serial | DrugCentral unique table identifier |
| pharma_class | struct_id | int4 | DrugCentral structure id for drug |
| pharma_class | type | varchar | Pharmacological class type according to the source |
| pharma_class | name | varchar | Pharmacological class name |
| pharma_class | class_code | varchar | Pharmacological class code according to the source |
| pharma_class | source | varchar | Source of the pharmacological class |
| pka | id | serial | DrugCentral unique table identifier |
| pka | struct_id | int4 | DrugCentral structure id for drug |
| pka | pka_level | varchar | The pKa type for multiprotic molecules |
| pka | value | float8 | The predicted pKa value |
| pka | pka_type | bpchar | Basic or acidic pKa type |
| prd2label | ndc_product_code | varchar | FDA NDC product code |
| prd2label | label_id | varchar | FDA label ID |
| prd2label | id | serial | DrugCentral unique table identifier to link products to labels |
| product | id | serial | DrugCentral unique product table identifier |
| product | ndc_product_code | varchar | FDA NDC product code |
| product | form | varchar | Drug product formulation |
| product | generic_name | varchar | Drug generic name |
| product | product_name | varchar | Drug product name |
| product | route | varchar | Administration route |
| product | marketing_status | varchar | Market status of a drug product in USA |
| product | active_ingredient_count | int4 | Number of active ingredients in the drug product |
| property | id | serial | DrugCentral unique property table identifier |
| property | property_type_id | int4 | DrugCentral unique property type identifier |
| property | property_type_symbol | varchar | DrugCentral property symbol for drug |
| property | struct_id | int4 | DrugCentral structure id for drug |
| property | value | float8 | Property value |
| property | reference_id | int4 | The DrugCentral reference identifier |
| property | reference_type | varchar | Reference type |
| property | source | varchar | Reference source |
| property_type | id | serial | DrugCentral unique property_type table identifier |
| property_type | category | varchar | Property class |
| property_type | name | varchar | Property name |
| property_type | symbol | varchar | Property abbreviation |
| property_type | units | varchar | Property measeurment unit |
| protein_type | id | serial | DrugCentral unique protein_type table identifier |
| protein_type | type | varchar | Protein class |
| ref_type | id | serial | Reference type identifier assigned in DrugCentral |
| ref_type | type | varchar | Reference type indexed in DrugCentral |
| reference | id | serial | table identifier |
| reference | pmid | int4 | PUBMED identifier of the reference |
| reference | doi | varchar | DOI number for the reference |
| reference | document_id | varchar | Drug label ID extracted from FDA, EMA, PMDA, etc |
| reference | type | varchar | Reference type according to ref_type table |
| reference | authors | varchar | Reference authors |
| reference | title | varchar | Reference title |
| reference | isbn10 | bpchar | Reference ISBN for books, book chapter, etc |
| reference | url | varchar | Link to the webpage of the reference |
| reference | journal | varchar | Journal name for the reference |
| reference | volume | varchar | Journal volume |
| reference | issue | varchar | Journal issue |
| reference | dp_year | int4 | Journal article publication year |
| reference | pages | varchar | Journal article pages |
| section | id | serial | Unique ID in DrugCentral table |
| section | text | text | Drug label content of the product |
| section | label_id | varchar | Drug label id |
| section | code | varchar | Drug label code |
| section | title | varchar | Drug label title |
| struct2atc | struct_id | int4 | DrugCentral structure id for drug |
| struct2atc | atc_code | bpchar | Drug ATC code |
| struct2atc | id | serial | Unique ID in DrugCentral table |
| struct2drgclass | id | serial | DrugCentral table identifier |
| struct2drgclass | struct_id | int4 | DrugCentral structure id for drug |
| struct2drgclass | drug_class_id | int4 | Drug class identifier from DrugCentral |
| struct2obprod | struct_id | int4 | DrugCentral structure id for drug |
| struct2obprod | prod_id | int4 | DrugCentral drug product identifier |
| struct2obprod | strength | varchar | Concentration of the active substance |
| struct2parent | struct_id | int4 | DrugCentral structure id for drug |
| struct2parent | parent_id | int4 | DrugCentral parentmol table identifier |
| struct_type_def | id | serial | DrugCentral unique identifier for structure type |
| struct_type_def | type | varchar | Type of structures defined in DrugCentral |
| struct_type_def | description | varchar | Short description of the structure type |
| structure_type | id | serial | DrugCentral table identifier |
| structure_type | struct_id | int4 | DrugCentral structure id for drug |
| structure_type | type | varchar | Type of structures defined in DrugCentral |
| structures | cd_id | serial | DrugCentral structure id for drug |
| structures | cd_formula | varchar | Drug chemical formula |
| structures | cd_molweight | float8 | Drug molecular weight |
| structures | id | int4 | DrugCentral structure ID |
| structures | clogp | float8 | Calculated clogP of the drug |
| structures | alogs | float8 | Calculated clogS of the drug |
| structures | cas_reg_no | varchar | CAS number of the drug |
| structures | tpsa | float4 | Calculated TPSA property of the drug |
| structures | lipinski | int4 | Calculated Lipinski rule for the drug |
| structures | name | varchar | Preffered drug name |
| structures | no_formulations | int4 | Number of formulations |
| structures | stem | varchar | INN STEM of the drug |
| structures | molfile | text | Depiction of the chemical structure of the drug |
| structures | mrdef | varchar | Drug description |
| structures | enhanced_stereo | bool | Signals a structure with chiral centers |
| structures | arom_c | int4 | Calculated number of aromatic C atoms of the drug |
| structures | sp3_c | int4 | Calculated number of sp3 C atoms of the drug |
| structures | sp2_c | int4 | Calculated number of sp2 C atoms of the drug |
| structures | sp_c | int4 | Calculated number of sp C atoms of the drug |
| structures | halogen | int4 | Calculated number of halogen atoms of the drug |
| structures | hetero_sp2_c | int4 | Calculated number of hetero and sp2 C atoms of the drug |
| structures | rotb | int4 | Number of rotatable bonds |
| structures | molimg | bytea | Image file of the chemical structure of the drug |
| structures | o_n | int4 | Number of H-bond acceptor |
| structures | oh_nh | int4 | Number of H-bond donors |
| structures | inchi | varchar | INCHI code |
| structures | smiles | varchar | SMILES code |
| structures | rgb | int4 | number of rigid bonds |
| structures | fda_labels | int4 | Has labels in FDA |
| structures | inchikey | bpchar | INCHI KEY |
| structures | status | varchar | Drug status regarding patent and/or marketing status od the product containing the drug substance |
| synonyms | syn_id | serial | DrugCentral synonim ID |
| synonyms | id | int4 | DrugCentral structure id for drug |
| synonyms | name | varchar | Drug name |
| synonyms | preferred_name | int2 | Preffered name of the drug |
| synonyms | parent_id | int4 | ID of a parent drug |
| synonyms | lname | varchar | Synonim names |
| target_class | l1 | varchar | Target class name |
| target_class | id | serial | Unique identifier for target class |
| target_component | id | serial | DrugCentral table identifier |
| target_component | accession | varchar | Unique entry identifier from UniProtKB |
| target_component | swissprot | varchar | Entry name identifier from UniProtKB |
| target_component | organism | varchar | The species expressing the target from UniProtKB |
| target_component | name | varchar | Target full-name from UniProtKB |
| target_component | gene | varchar | Name of the gene encoding the protein from UniProtKB |
| target_component | geneid | int8 | Gene identifier from UniProtKB |
| target_component | tdl | varchar | Target development level, as defined at http://juniper.health.unm.edu/tcrd/ or https://datascience.unm.edu/tcrd/ |
| target_dictionary | id | serial | DrugCentral table identifier |
| target_dictionary | name | varchar | Target full-name from UniProtKB |
| target_dictionary | target_class | varchar | DrugCentral target class definition |
| target_dictionary | protein_components | int2 | Number of components of a target |
| target_dictionary | protein_type | varchar | Target type as defined in DrugCentral |
| target_dictionary | tdl | varchar | Target development level, as defined at http://juniper.health.unm.edu/tcrd/ or https://datascience.unm.edu/tcrd/ |
| target_go | id | bpchar | Gene ontology ID |
| target_go | term | varchar | Term description |
| target_go | type | bpchar | Type of GO term |
| target_keyword | id | bpchar | DrugCentral table identifier |
| target_keyword | descr | varchar | Target description |
| target_keyword | category | varchar | Term describing the functional category for a target |
| target_keyword | keyword | varchar | DrugCentral keyword |
| td2tc | target_id | int4 | Target ID extracted from target_dictionary table |
| td2tc | component_id | int4 | Target ID extracted from target_component table |
| tdgo2tc | id | serial | DrugCentral table identifier |
| tdgo2tc | go_id | bpchar | Gene ontology ID |
| tdgo2tc | component_id | int4 | Target ID corresponding to target_component table |
| tdkey2tc | id | serial | DrugCentral table identifier |
| tdkey2tc | tdkey_id | bpchar | Identifier corresponding to target_keyword table |
| tdkey2tc | component_id | int4 | Target ID corresponding to target_component table |
| vetomop | omopid | serial | OMOP identifier for veterinary drug indications |
| vetomop | struct_id | int4 | DrugCentral structure id for veterinary drug |
| vetomop | species | varchar | Species Identifier |
| vetomop | relationship_type | varchar | Type of concept name: indication/contraindication |
| vetomop | concept_name | varchar | Concept name according to UMLS MetaThesaurus |
| vetprod | prodid | serial | DrugCentral unique table identifier for veterinary drug products |
| vetprod | appl_type | bpchar | FDA application type associated with the product id |
| vetprod | appl_no | bpchar | FDA application number associated with the product id |
| vetprod | trade_name | varchar | Trade name of the product |
| vetprod | applicant | varchar | Name of the applying company |
| vetprod | active_ingredients_count | int4 | Number of active ingredients in the drug product |
| vetprod2struct | prodid | int4 | DrugCentral unique table identifier for veterinary drug products |
| vetprod2struct | struct_id | int4 | DrugCentral structure id for veterinary drug |
| vetprod_type | id | int4 | DrugCentral table identifier |
| vetprod_type | appl_type | bpchar | FDA application type associated with the product id |
| vetprod_type | description | varchar | Veterinary product type description |
| vettype | prodid | int4 | DrugCentral unique table identifier for veterinary drug products |
| vettype | type | varchar | Veterinary drug type |
|  |
