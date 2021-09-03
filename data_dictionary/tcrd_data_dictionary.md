| | Primary Table | Column name | Column description | potential values; example value | DATA TYPE | distinct_values | DATA SOURCE |
|-----|------------------------|-----------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 0 | alias | id | Alias identifier | 1-150037 | int(11) | 150037 | |
| 1 | alias | protein_id | Foreign key to column id in table protein. | 1-19673 | int(11) | 19673 | |
| 2 | alias | type | Alias type | uniport, symbol | enum('symbol','uniprot') | 2 | |
| 3 | alias | value | String containing the target alias (synonym) value | Q53FB3 | varchar(255) | 125167 | |
| 4 | alias | dataset_id | Foreign key to column `id` in table dataset. | 1 | int(11) | 2 | |
| 5 | clinvar | id | TCRD ClinVar identifier | 1-511408 | int(11) | 511408 | |
| 6 | clinvar | protein_id | Foreign key to column id in table protein. | 6107 | int(11) | 2947 | |
| 7 | clinvar | clinvar_phenotype_id | Foreign key to column id in table clinvar_phenotype. | 4077 | int(11) | 5803 | |
| 8 | clinvar | alleleid | ClinVar allele identifier | 15046 | int(11) | 97381 | |
| 9 | clinvar | type | Type of variant | unique types, single nucleotide variant, short repeat, deletion, duplication, indel, insertion, inversion, NT expansion, undetermined variant | varchar(40) | 9 | |
| 10 | clinvar | name | ClinVar "preferred name of the variation" record | NM_000410.3(HFE):c.187C>G (p.His63Asp) | text | 97381 | |
| 11 | clinvar | review_status | ClinVar reports the level of review supporting the assertion of clinical significance for the variation as review status | criteria provided, multiple submitters, no conflicts, reviewed by expert panel | varchar(60) | 2 | |
| 12 | clinvar | clinical_significance | Clinical significance | Pathogenic, other; Pathogenic; Pathogenic/Likely pathogenic; Benign; Likely pathogenic; drug response; Benign/Likely benign; Likely benign, other; Likely benign; Pathogenic/Likely pathogenic, other; Benign/Likely benign, other; Benign, other; Pathogenic/Likely pathogenic, risk factor; Uncertain significance, other; Likely benign, risk factor; Pathogenic/Likely pathogenic, drug response; Pathogenic, drug response; Benign/Likely benign, risk factor; Benign, drug response; Pathogenic, risk factor; Benign, risk factor; other, risk factor; Uncertain significance, association; drug response, other; Likely benign, drug response; Likely pathogenic, risk factor | varchar(80) | 27 | |
| 13 | clinvar | clin_sig_simple | Binary indicator for clinical significance (1=Yes, 0=No) | 0,1 | int(11) | 0 | |
| 14 | clinvar | last_evaluated | date last evaluated | 2019-01-09 | date | 1883 | |
| 15 | clinvar | dbsnp_rs | dbSNP RefSNP (rs) IDs | 1799945 | int(11) | 91635 | |
| 16 | clinvar | dbvarid | variation id | nsv1067859, nsv1197557, nsv513781, nsv1197451, nsv513792, nsv1067916 | varchar(10) | 6 | |
| 17 | clinvar | origin | The genetic origin of the variant for each observation. Single or multiple values between germline, de novo, somatic, maternal, paternal, inherited, unknown, uniparental, biparental are allowed. Uniparental and biparental are intended for the context of uniparental disomy, not to indicate zygosity. | biparental;germline;unknown | varchar(60) | 67 | |
| 18 | clinvar | origin_simple | Simplified allele origin. ClinVar includes interpretations of variants identified in the germline and as somatic events. Note that allele origin refers to an observation of a variant, not the variant itself, so the same variant may have been reported both as germline and as somatic. | germline, germline/somatic, somatic, unknown | varchar(20) | 4 | |
| 19 | clinvar | assembly | genome assembly name | GRCh37, GRCh38, NCBI36 | varchar(8) | 3 | |
| 20 | clinvar | chr | chromosome | 1-26, MT, X, Y, na | varchar(2) | 26 | |
| 21 | clinvar | chr_acc | nucleotide | NC_000006.12 | varchar(20) | 0 | |
| 22 | clinvar | start | Variant start location on chromosome | 26090951 | int(11) | | |
| 23 | clinvar | stop | Variant stop location on chromosome | 26090951 | int(11) | | |
| 24 | clinvar | number_submitters | Number of variant submitters | 13 | int(2) | | |
| 25 | clinvar | tested_in_gtr | The Genetic Testing Registry (GTR) is a database of genetic test information submitted by test providers. | TRUE | tinyint(1) | | |
| 26 | clinvar | submitter_categories | | TRUE | tinyint(1) | | |
| 27 | clinvar_phenotype | id | TCRD ClinVar phenotype identifier | 1-12280 | int(11) | 12280 | |
| 28 | clinvar_phenotype | name | ClinVar phenotype name | Nephronophthisis | varchar(255) | 12279 | |
| 29 | clinvar_phenotype_xref | id | Tcrd ClinVar phenotype external reference identifier | 1-22373 | | 22373 | |
| 30 | clinvar_phenotype_xref | clinvar_phenotype_id | Foreign key to column id in table clinvar_phenotype. | 1-10297 | | 10297 | |
| 31 | clinvar_phenotype_xref | source | Name of source for external reference | Orphanet, SNOMED CT, MedGen, HPO, OMIM, MeSH, EFO, Gene | tinyint(1) | 8 | |
| 32 | clinvar_phenotype_xref | value | External reference ID | ORPHA79172 | tinyint(1) | 22361 | |
| 33 | cmpd_activity | id | TCRD compound identifier. The id is unique in the target table. | 4 | int(11) | 500993 | |
| 34 | cmpd_activity | target_id | Foreign key to column id in table target. | 3000 | int(11) | 2051 | |
| 35 | cmpd_activity | catype | Foreign key to column name in table cmpd_activity_type. | ChEMBL, Guide to Pharmacology | varchar(255) | 2 | |
| 36 | cmpd_activity | cmpd_id_in_src | Source compound ID | CHEMBL186240 | varchar(255) | 271016 | |
| 37 | cmpd_activity | cmpd_name_in_src | Source compound name | N-(5-Cyclobutyl-thiazol-2-yl)-2-(1H-indol-3-yl)-acetamide | text | 283853 | |
| 38 | cmpd_activity | smiles | Compound structure in SMILES format | O=C(Cc1c[nH]c2ccccc12)Nc3ncc(s3)C4CCC4 | text | 269547 | |
| 39 | cmpd_activity | act_value | Bioactivity measurement value | 7.8 | decimal(10,8) | 1322 | |
| 40 | cmpd_activity | act_type | Bioactivity measurement type | IC50 | varchar(255) | 9 | |
| 41 | cmpd_activity | reference | Literature reference | Bioorg. Med. Chem. Lett., (2004) 14:22:5521 | text | 16125 | |
| 42 | cmpd_activity | pubmed_ids | PubMed IDs | 15482916 | text | 18504 | |
| 43 | cmpd_activity | cmpd_pubchem_cid | PubChem CID | 9815202 | int(11) | 249460 | |
| 44 | cmpd_activity | lychi_h4 | The NCATS Layered Chemical Identifier (LyChI) is a chemical standardization tool that generates a unique hash for chemicals that is layered and used for quick fuzzy uniqueness checks and searches. A unique feature of the LyChI hash keys is that they are, to a certain extent, lexicologically meaningful (https://github.com/ncats/lychi). Level 4 of the identifier is used here. | 2DB427URCFNS | varchar(15) | 266188 | |
| 45 | cmpd_activity_type | name | Name of the source for the compound activity data | ChEMBL, Guide to Pharmacology | varchar(255) | 2 | |
| 46 | cmpd_activity_type | description | Description of the source for the compound activity data | The IUPHAR/BPS Guide to PHARMACOLOGY | text | 2 | |
| 47 | compartment | id | Cellular compartment identifier | 2 | int(11) | 1075822 | |
| 48 | compartment | ctype | Foreign key to column name in table compartment_type. | Human Cell Atlas, JensenLab Experiment, JensenLab Knowledge, JensenLab Prediction, JensenLab Text Mining | varchar(255) | 5 | |
| 49 | compartment | target_id | Foreign key to column id in table target. | (null) | int(11) | (null) | |
| 50 | compartment | protein_id | Foreign key to column id in table protein. | 15604 | int(11) | 18813 | |
| 51 | compartment | go_id | Gene ontology identifier for the cell compartment | GO:0005739 | varchar(255) | 2984 | |
| 52 | compartment | go_term | Gene ontology term for the cell compartment | Mitochondria | text | 3000 | |
| 53 | compartment | evidence | Empty (reserved for future use) | (null) | varchar(255) | 118 | |
| 54 | compartment | zscore | Empty (reserved for future use) | (null) | decimal(4,3) | 4715 | |
| 55 | compartment | conf | Empty (reserved for future use) | (null) | decimal(2,1) | 33 | |
| 56 | compartment | url | Empty (reserved for future use) | (null) | text | 184602 | |
| 57 | compartment | reliability | Reliability of association between target and cellular compartment | Supported, Approved, Validated, (null) | enum('Supported','Approved','Validated') | 4 | |
| 58 | compartment_type | name | Name of the source for the cellular compartment data | Human Cell Atlas, JensenLab Experiment, JensenLab Knowledge, JensenLab Prediction, JensenLab Text Mining | varchar(255) | 5 | |
| 59 | compartment_type | description | Description of the source for the cellular compartment data | Human Cell Atlas protein locations, minus rows with Uncertain reliability. Experiment channel subcellular locations from JensenLab COMPARTMENTS resource, filtered for confidence scores of 3 or greater. Knowledge channel subcellular locations from JensenLab COMPARTMENTS resource, filtered for confidence scores of 3 or greater. Prediction channel subcellular locations from JensenLab COMPARTMENTS resource, filtered for confidence scores of 3 or greater. Text Mining channel subcellular locations from JensenLab COMPARTMENTS resource, filtered for zscore of 3.0 or greater. | text | 5 | |
| 60 | disease | id | TCRD disease identifier | 1-407551 | int(11) | 407551 | |
| 61 | disease | dtype | Foreign key to column name in table disease_type. | CTD, DisGeNET, DrugCentral Indication, eRAM, Expression Atlas, JensenLab Experiment COSMIC, JensenLab Experiment DistiLD, JensenLab Knowledge GHR, JensenLab Knowledge UniProtKB-KW, JensenLab Text Mining, Monarch, UniProt Disease | varchar(255) | 12 | |
| 62 | disease | protein_id | Foreign key to column id in table protein. | 1 | int(11) | 18879 | |
| 63 | disease | nhprotein_id | Foreign key to column id in table nhprotein. | (null) | int(11) | 0 | |
| 64 | disease | name | Disease name | Cystathioninuria | text | 20032 | |
| 65 | disease | did | Disease identifier | MIM:219500, OMIM:219500, C0220993, DOID:0090142 | varchar(20) | 28232 | |
| 66 | disease | evidence | Evidence of association between target and disease | 2 PubMed IDs; 3 SNPs | text | 3225 | |
| 67 | disease | zscore | Standard score for the strength of association between target and disease | (null) | decimal(4,3) | 4511 | |
| 68 | disease | conf | Confidence level for the strength of association between target and disease | (null) | decimal(2,1) | 37 | |
| 69 | disease | description | Disease description | Autosomal recessive phenotype characterized by abnormal accumulation of plasma cystathionine, leading to increased urinary excretion. | text | 3887 | |
| 70 | disease | reference | Empty (reserved for future use) | (null) | varchar(255) | 0 | |
| 71 | disease | drug_name | Drug indicated for a specific disease, having a pharmacological mechanism of action by acting of a specific target | cepharanthine | text | 1443 | |
| 72 | disease | log2foldchange | Differential expression log2 fold-change for differentially expressed gene in disease patient tissue versus matched normal tissue in Expression Atlas | -2.329 | decimal(5,3) | 5245 | |
| 73 | disease | pvalue | p-value for differentially expressed gene in disease patient tissue versus matched normal tissue in Expression Atlas | 0.01 | varchar(255) | 137079 | |
| 74 | disease | score | DisGeNET score for gene-disease association | (null) | decimal(16,15) | 83 | |
| 75 | disease | source | Source of target-disease association | (null) | varchar(255) | 135 | |
| 76 | disease | O2S | | (null) | decimal(16,13) | 0 | |
| 77 | disease | S2O | | 96.18 | decimal(16,13) | 5626 | |
| 78 | disease_type | name | Name of the source for the target-disease association data | CTD, DisGeNET, DrugCentral Indication, eRAM, Expression Atlas, JensenLab Experiment COSMIC, JensenLab Experiment DistiLD, JensenLab Knowledge GHR, JensenLab Knowledge UniProtKB-KW, JensenLab Text Mining, Monarch, UniProt Disease | varchar(255) | 12 | |
| 79 | disease_type | description | Description of the source for the target-disease association data | Disease association from UniProt comment field with type="disease" | text | 12 | Gene-Disease associations with direct evidence from the Comparative Toxicogenomics Database. Currated disease associations from DisGeNET (http://www.disgenet.org/). Disease indications and associated drug names from Drug Central. Currated gene disease associations from eRAM. Target-Disease associations from Expression Atlas where the log2 fold change in gene expresion in disease sample vs reference sample is greater than 1.0. Only reference samples "normal" or "healthy" are selected. Data is derived from the file: ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/atlas/experiments/atlas-latest-data.tar.gz, JensenLab Experiment channel using COSMIC, JensenLab Experiment channel using DistiLD, JensenLab Knowledge channel using GHR, JensenLab Knowledge channel using UniProtKB-KW, JensenLab Text Mining channel, Gene-Disease associations from Monarch that have S2O and/or O2S score(s), Disease association from UniProt comment field with type="disease" |
| 80 | do | doid | Disease ontology identifier (from https://disease-ontology.org) | DOID:0001816 | varchar(12) | 9233 | https://disease-ontology.org |
| 81 | do | name | Disease name | angiosarcoma | text | 9233 | |
| 82 | do | def | Disease definition | A vascular cancer that derives_from the cells that line the walls of blood vessels or lymphatic vessels. | text | 6118 | |
| 83 | do_parent | doid | Disease identifier (foreign key to column doid in table do) | DOID:0080337 | varchar(12) | 9232 | |
| 84 | do_parent | parent_id | Parent disease identifier (foreign key to column doid in table do) | DOID:0050737 | varchar(12) | 2097 | |
| 85 | do_xref | doid | Foreign key to column doid in table do. | DOID:10588 | varchar(12) | 8635 | |
| 86 | do_xref | db | Source of the external reference identifier | CSP2005, DERMO, DO, EFO, GARD, ICD-10, ICD10CM, ICD9CM, ICD9CM_2006, JA, KEGG, ls, MEDDRA, MESH, MTH, MTHICD9_2006, NCI, NCI2004_11_17, OMIM, ORDO, sn, SNOMECT, SNOMED_CT_US_2018_03_01, SNOMEDCT_US_2018_03_01, stedman, UMLS_CUI | varchar(24) | 25 | |
| 87 | do_xref | value | External reference identifier | 2042-2215, E75.2, 358.3 | varchar(24) | 36392 | |
| 88 | drgc_resource | id | TCRD identifier for the drgc_resource table containing links and metadata about the resources generated by the Illuminating the druggable genome (IDG) experimental data and resource generation centers (DRGC) | 1-320 | int(11) | 320 | |
| 89 | drgc_resource | rssid | Resource Submission System (RSS) identifier | https://repo.metadatacenter.org/template-instances/6b9c4cec-0c93-4b49-927b-6f81f55df901 | text | 320 | |
| 90 | drgc_resource | resource_type | Resource type | Cell, Mouse, Expression, Mouse Phenotype, NanoBRET, GPCR Mouse Imaging, Chemical Tool | varchar(255) | 7 | |
| 91 | drgc_resource | target_id | Foreign key to column id in table target. | 1-149 | int(11) | 149 | |
| 92 | drgc_resource | json | Resource metadata in json format | json file | text | 320 | |
| 93 | drug_activity | id | TCRD drug activity identifier | 1-4004 | int(11) | 4004 | |
| 94 | drug_activity | target_id | Foreign key to column id in table target. | 1-993 | int(11) | 993 | |
| 95 | drug_activity | drug | Drug name | avapritinib | varchar(255) | 1642 | |
| 96 | drug_activity | act_value | Bioactivity measurement value | 9.62 | decimal(10,8) | 1019 | |
| 97 | drug_activity | act_type | Bioactivity measurement type | (null), IC50, Ki, Kd, EC50, ID50, ED50, MEC, IC90, A2, Kb, AC50 | varchar(255) | 12 | |
| 98 | drug_activity | action_type | Pharmacological action type | INHIBITOR, PHARMACOLOGICAL CHAPERONE, AGONIST, ANTIBODY BINDING, ANTAGONIST, BLOCKER, ACTIVATOR, INVERSE AGONIST, MODULATOR, PARTIAL AGONIST, OPENER, POSITIVE ALLOSTERIC MODULATOR, NEGATIVE ALLOSTERIC MODULATOR, GATING INHIBITOR,, RELEASING AGENT, POSITIVE MODULATOR, SUBSTRATE, ALLOSTERIC ANTAGONIST, (null), BINDING AGENT, ALLOSTERIC MODULATOR, ANTISENSE INHIBITOR | varchar(255) | 22 | |
| 99 | drug_activity | has_moa | Mechanism of Action target association as defined by DrugCentral | True, False | tinyint(1) | 2 | |
| 100 | drug_activity | source | Source of knowledge | SCIENTIFIC LITERATURE, DRUG LABEL, KEGG DRUG, IUPHAR, CHEMBL | varchar(255) | 5 | |
| 101 | drug_activity | reference | Source URL | https://www.accessdata.fda.gov/drugsatfda_docs/label/2020/212608s000lbl.pdf | text | 1716 | |
| 102 | drug_activity | smiles | Drug structure in SMILES format | CN1C=C(C=N1)C1=CN2N=CN=C(N3CCN(CC3)C3=NC=C(C=N3)[C@@](C)(N)C3=CC=C(F)C=C3)C2=C1 | text | 1495 | |
| 103 | drug_activity | cmpd_chemblid | ChEMBL molecule ID | CHEMBL4204794 | varchar(255) | 1513 | |
| 104 | drug_activity | nlm_drug_info | Drug mechanism of action (where available) as described in the drug label. | Avapritinib is a tyrosine kinase inhibitor that targets PDGFRA and PDGFRA D842 mutants as well as multiple KIT exon 11, 11/17 and 17 mutants with half maximal inhibitory concentrations (IC50s) less than 25 nM. Certain mutations in PDGFRA and KIT can result in the autophosphorylation and constitutive activation of these receptors which can contribute to tumor cell proliferation. Other potential targets for avapritinib include wild type KIT, PDGFRB, and CSFR1. | text | 1473 | https://druginfo.nlm.nih.gov/drugportal/ |
| 105 | drug_activity | cmpd_pubchem_cid | PubChem CID | (null) | int(11) | (null) | |
| 106 | drug_activity | dcid | DrugCentral ID (drug compound) | integer | int(11) | 1642 | |
| 107 | drug_activity | lychi_h4 | The NCATS Layered Chemical Identifier (LyChI) is a chemical standardization tool that generates a unique hash for chemicals that is layered and used for quick fuzzy uniqueness checks and searches. A unique feature of the LyChI hash keys is that they are, to a certain extent, lexicologically meaningful (https://github.com/ncats/lychi). Level 4 of the identifier is used here. | BUBUSK1338HA | varchar(15) | 1489 | |
| 108 | dto | dtoid | Drug Target Ontology (DTO) identifier (from http://drugtargetontology.org/) | BTO_0000007 | varchar(255) | 17779 | |
| 109 | dto | name | DTO term name | HEK-293 cell | text | 17733 | |
| 110 | dto | parent_id | DTO identifier for parent term (foreign key to column dtoid in table dto) | BTO_0000067 | varchar(255) | 2841 | |
| 111 | dto | def | DTO term definition | Established from a human primary embryonal kidney transformed by adenovirus type 5.' | text | 5706 | |
| 112 | expression | id | TCRD identifier for expression table | 1-26935759 | int(11) | 26935759 | |
| 113 | expression | etype | Foreign key to column name in table expression_type. | CCLE, Cell Surface Protein Atlas, Consensus, GTEx, HCA RNA, HPA, HPM Gene, HPM Protein, JensenLab Experiment Cardiac proteome, JensenLab Experiment Exon array, JensenLab Experiment GNF, JensenLab Experiment HPA, JensenLab Experiment HPA-RNA, JensenLab Experiment HPM, JensenLab Experiment RNA-seq, JensenLab Experiment UniGene, JensenLab Knowledge UniProtKB-RC, JensenLab Text Mining, UniProt Tissue | varchar(255) | 18 | |
| 114 | expression | target_id | Foreign key to column id in table target. | (null) | int(11) | 0 | |
| 115 | expression | protein_id | Foreign key to column id in table protein. | 3 | int(11) | 19945 | |
| 116 | expression | tissue | Tissue where expression was measured | Brain | text | 5721 | |
| 117 | expression | qual_value | Qualitative level of expression | (null), Not detected, Medium, High, Low | enum('Not detected','Low','Medium','High') | 5 | |
| 118 | expression | integer_value | Numeric value of expression | float | decimal(12,6) | 4523984 | |
| 119 | expression | boolean_value | | TRUE, (null) | tinyint(1) | 2 | |
| 120 | expression | string_value | Textual description of expression results, using different formats for each expression source | (null) | text | 53449 | |
| 121 | expression | pubmed_id | Pubmed ID for the paper reporting the expression results | 17974005 | int(11) | 10490 | |
| 122 | expression | evidence | Level of evidence | (null), CURATED, Approved, Enhanced, Supported | varchar(255) | 5 | |
| 123 | expression | zscore | Standard score for the strength of association between target and tissue | (null) | decimal(4,3) | 4046 | |
| 124 | expression | conf | Confidence level for the strength of association between target and tissue | (null) | decimal(2,1) | 0 | |
| 125 | expression | oid | Tissue ontology ID | (null) | varchar(20) | 4060 | |
| 126 | expression | confidence | Binary level of confidence | (null), true, false | tinyint(1) | 3 | |
| 127 | expression | url | URL of specific expression data | (null) | text | 60782 | |
| 128 | expression | cell_id | | (null) | varchar(20) | 1155 | |
| 129 | expression | uberon_id | Foreign key to column uid in table uberon. | UBERON:0000955 | varchar(20) | 1269 | |
| 130 | expression_type | name | Name of the source for the expression data | CCLE, Cell Surface Protein Atlas, Consensus, GTEx, HCA RNA, HPA, HPM Gene, HPM Protein, JensenLab Experiment Cardiac proteome, JensenLab Experiment Exon array, JensenLab Experiment GNF, JensenLab Experiment HPA, JensenLab Experiment HPA-RNA, JensenLab Experiment HPM, JensenLab Experiment RNA-seq, JensenLab Experiment UniGene, JensenLab Knowledge UniProtKB-RC, JensenLab Text Mining, UniProt Tissue | varchar(255) | 18 | |
| 131 | expression_type | data_type | Foreign key to column name in table data_type. | integer, Boolean, String | varchar(7) | 3 | |
| 132 | expression_type | description | Description of the source for the expression data | Broad Institute Cancer Cell Line Encyclopedia expression data. | text | 18 | Broad Institute Cancer Cell Line Encyclopedia expression data., Cell Surface Protein Atlas protein expression in cell lines., Qualitative consensus expression value calulated from GTEx, HPA and HPM data aggregated according to manually mapped tissue types, GTEx V4 RNA-SeQCv1.1.8 Log Median RPKM and qualitative expression values per SMTSD tissue type, Human Cell Atlas gene expression in cell lines, Human Protein Atlas normal tissue expression values, Human Proteome Map gene-level Log and qualitative expression values., Human Proteome Map protein-level Log and qualitative expression values., JensenLab Experiment channel using Cardiac proteome, JensenLab Experiment channel using Exon array, JensenLab Experiment channel using GNF, JensenLab Experiment channel using Human Protein Atlas IHC, JensenLab Experiment channel using Human Protein Atlas RNA, JensenLab, Experiment channel using Humap Proteome Map, JensenLab Experiment channel using RNA-seq, JensenLab Experiment channel using UniGene, JensenLab Knowledge channel using UniProtKB-RC, JensenLab Text Mining channel, Tissue and PubMed ID from UniProt |
| 133 | extlink | id | TCRD external link identifier | | | | |
| 134 | extlink | protein_id | Foreign key to column id in table protein | | | | |
| 135 | extlink | source | Source of external link | GlyGen,TIGA | | | |
| 136 | extlink | url | URL of external link | https://glygen.org/protein/P32929 | | | |
| 137 | feature | id | TCRD identifier for protein feature table | 1- 564259 | int(11) | 564259 | |
| 138 | feature | protein_id | Foreign key to column id in table protein. | integer | int(11) | 20412 | |
| 139 | feature | type | Protein feature type | chain, binding site, modified residue, splice variant, sequence variant, helix, strand, turn, short sequence motif, sequence conflict, domain, repeat, nucleotide phosphate-binding region, region of interest, compositionally biased region, cross-link, initiator, methionine, calcium-binding region, lipid moiety-binding region, mutagenesis site, DNA-binding region, transmembrane region, coiled-coil region, active site, metal ion-binding site, site, topological domain, signal peptide, propeptide, glycosylation site, disulfide bond, zinc finger region, transit peptide, intramembrane region, peptide, non-standard amino acid, non-terminal residue, non-consecutive residues | varchar(255) | 38 | |
| 140 | feature | description | Protein feature description | Cystathionine gamma-lyase | text | 134583 | |
| 141 | feature | srcid | Protein feature source id | PRO_0000114749 | varchar(255) | 130947 | |
| 142 | feature | evidence | | 5 6 7 12 | varchar(255) | 9158 | |
| 143 | feature | begin | Position in sequence where protein feature begins | 1 | int(11) | 5218 | |
| 144 | feature | end | Position in sequence where protein feature begins | 405 | int(11) | 5282 | |
| 145 | feature | position | Position in sequence of the single amino acid feature | (null) | int(11) | 4940 | |
| 146 | feature | original | Empty - reserved for future use | (null) | varchar(255) | 0 | |
| 147 | feature | variation | Empty - reserved for future use | (null) | varchar(255) | 0 | |
| 148 | gene_attribute | id | TCRD identifier for gene_attribute table | 1-65549760 | int(11) | 65549760 | |
| 149 | gene_attribute | protein_id | Foreign key to column id in table protein. | 1897 | int(11) | 18789 | |
| 150 | gene_attribute | gat_id | Foreign key to column id in table gene_attribute_type. | 1 | int(11) | 113 | |
| 151 | gene_attribute | name | Gene attribute name | 2-LTR circle formation/Reactome Pathways | text | 321763 | |
| 152 | gene_attribute | value | Gene attribute value | 1, -1 | int(1) | 1 | |
| 153 | gene_attribute_type | id | TCRD identifier for the gene_attribute_type table | integer | int(11) | 113 | |
| 154 | gene_attribute_type | name | Name of data source for gene attribute types | COSMIC Cell Line Gene Mutation Profiles | varchar(255) | 113 | |
| 155 | gene_attribute_type | association | Type of association | gene-cell line associations by mutation of gene in cell line | text | 113 | |
| 156 | gene_attribute_type | description | Description of data source | The Catalogue of Somatic Mutations in Cancer is a database of information about somatic mutations in cancer obtained from curation of relevant literature and from high-throughput sequencing data generated by the Cancer Genome Project and other cancer profiling projects such as The Cancer Genome Atlas. Specifically, COSMIC collects information about point mutations, gene fusions, genomic rearrangements, and copy integer variation in cancer tissue samples and cancer cell lines. | text | 113 | |
| 157 | gene_attribute_type | resource_group | Type of data source | genomics, transcriptomics, proteomics, physical interactions | enum('omics','genomics','proteomics','physical interactions','transcriptomics','structural or functional annotations','disease or phenotype associations') | 113 | |
| 158 | gene_attribute_type | measurement | Type of measurement or literature curation to establish association | gene mutation by data aggregation | varchar(255) | 113 | |
| 159 | gene_attribute_type | attribute_group | Gene attribute group | cell line, cell type or tissue | varchar(255) | 113 | |
| 160 | gene_attribute_type | attribute_type | Gene attribute type | cell line | varchar(255) | 113 | |
| 161 | gene_attribute_type | pubmed_ids | Pubmed IDs of reference papers | 19906727|20952405 | text | 113 | |
| 162 | gene_attribute_type | url | URL of data source | http://cancer.sanger.ac.uk/cancergenome/projects/cosmic/ | text | 113 | |
| 163 | generif | id | TCRD identifier for the Gene Reference into Function table | 1-740376 | int(11) | 740376 | |
| 164 | generif | protein_id | Foreign key to column id in table protein. | 1 | int(11) | 16411 | |
| 165 | generif | pubmed_ids | Pubmed IDs of reference papers | 19692168|15151507|20634891|18701025|19625176|19324355|18676680|19161160|19913121 | text | 473814 | |
| 166 | generif | text | Gene Reference into Function (GeneRIF) text | Observational study of gene-disease association. (HuGE Navigator) | text | 514140 | |
| 167 | generif | years | Years when the reference papers were published | 2010|2004|2010|2008|2009|2010|2008|2009|2009 | text | 6041 | |
| 168 | goa | id | TCRD identifier for the Gene Ontology table | 1-258719 | int(11) | 258719 | |
| 169 | goa | protein_id | Foreign key to column id in table protein. | integer | int(11) | 19100 | |
| 170 | goa | go_id | GO term id | GO:0005737 | varchar(255) | 17903 | |
| 171 | goa | go_term | GO term name | C:cytoplasm | text | 17903 | |
| 172 | goa | evidence | Type of evidence | IBA, TAS, HDA, IEA, IDA, IPI, IMP, ISS, ISM, IGI, NAS, IEP, EXP, ISA, HEP, IC, HMP, ISO | text | 18 | |
| 173 | goa | goeco | Evidence and Conclusion Ontology (ECO) terms that describe types of evidence and assertion methods as described at https://evidenceontology.org/ | ECO:0000318, ECO:0000304, ECO:0007005, ECO:0000501, ECO:0000314, ECO:0000353, ECO:0000315, ECO:0000250, ECO:0000255, ECO:0000316, ECO:0000303, ECO:0000270, ECO:0000269, ECO:0000247, ECO:0007007, ECO:0000305, ECO:0007001, ECO:0000266 | varchar(255) | 18 | |
| 174 | goa | assigned_by | Data source for GO term | UniProtKB | varchar(50) | 35 | |
| 175 | goa | go_type | Type of GO term | Component, Function, Process | enum('Component','Function','Process') | 3 | |
| 176 | gtex | id | TCRD identifier for the Genotype-Tissue Expression (GTEx) table | 1-1805436 | int(11) | 1805436 | |
| 177 | gtex | protein_id | Foreign key to column id in table protein | integer | int(11) | 18474 | |
| 178 | gtex | tissue | GTEx tissue name | Adipose - Subcutaneous | text | 53 | |
| 179 | gtex | gender | GTEx tissue biological sex | M, F | enum('F','M') | 2 | |
| 180 | gtex | tpm | Gene and transcript expression shown in Transcripts Per Million (TPM) units | 23.220000 | decimal(12,6) | 45047 | |
| 181 | gtex | tpm_rank | Rank percentile [0-1] | 0.653 | decimal(4,3) | 628 | |
| 182 | gtex | tpm_rank_bysex | Rank by sex percentile [0-1] | 0.627 | decimal(4,3) | 478 | |
| 183 | gtex | tpm_level | Low, Medium or High from rank percentiles with cutoffs .25 and .75 | Low, Medium, High | enum('Not detected','Low','Medium','High') | 3 | |
| 184 | gtex | tpm_level_bysex | Low, Medium or High from rank percentiles with cutoffs .25 and .75, by sex | Low, Medium, High | enum('Not detected','Low','Medium','High') | 3 | |
| 185 | gtex | tpm_f | Transcripts per million (TPM) - female | 23.220000 | decimal(12,6) | 39018 | |
| 186 | gtex | tpm_m | Transcripts per million (TPM) - male | 22.280000 | decimal(12,6) | 39085 | |
| 187 | gtex | log2foldchange | LOG2(TPM_F/TPM_M) | 0.057 | decimal(4,3) | 0 | |
| 188 | gtex | tau | Tau is tissue specificity index (Yanai et al., 2004) | 0.801 | decimal(4,3) | 661 | |
| 189 | gtex | tau_bysex | Tau is tissue specificity index (Yanai et al., 2004), by sex | 0.798 | decimal(4,3) | 687 | |
| 190 | gtex | uberon_id | UBERON ID for tissue | UBERON:0002369 | varchar(20) | 48 | |
| 191 | gwas | id | TCRD identifier for the Genome Wide Association Studies (GWAS) data table | 1-124149 | int(11) | 124149 | |
| 192 | gwas | protein_id | Foreign key to column id in table protein. | 15243 | int(11) | 13116 | |
| 193 | gwas | disease_trait | TCRD identifier for the GWAS table | Waist-to-hip ratio adjusted for BMI | varchar(255) | 3180 | |
| 194 | gwas | snps | SNP IDs (RefSNP or other) | rs2179129 | text | 62952 | |
| 195 | gwas | pmid | PubMed ID | 26426971 | int(11) | 3230 | |
| 196 | gwas | study | Study name | The Influence of Age and Sex on Genetic Associations with Adult Body Size and Shape: A Large-Scale Genome-Wide Interaction Study. | text | 3230 | |
| 197 | gwas | context | SNP functional class | 3_prime_UTR_variant | text | 105 | |
| 198 | gwas | intergenic | Is SNP integenic? | FALSE, TRUE, (null) | tinyint(1) | 3 | |
| 199 | gwas | p_value | p-value for association | 1.00E-15 | double | 1740 | |
| 200 | gwas | or_beta | Odds ratio (OR) or Beta value as measures of effect size | 0.0266488 | float | 30345 | |
| 201 | gwas | cnv | Copy number variation | N | char(1) | 1 | |
| 202 | gwas | mapped_trait | EFO mapped trait (name) | BMI-adjusted waist-hip ratio | text | 2693 | |
| 203 | gwas | mapped_trait_uri | EFO mapped trait (URI) | http://www.ebi.ac.uk/efo/EFO_0007788 | text | 2693 | |
| 204 | hgram_cdf | id | TCRD identifier for the Harmonogram CDF data | 1-1167880 | int(11) | 1167880 | |
| 205 | hgram_cdf | protein_id | Foreign key to column id in table protein. | integer | int(11) | 18789 | |
| 206 | hgram_cdf | type | Foreign key to column name in table gene_attribute_type. | Allen Brain Atlas Prenatal Human Brain Tissue Gene Expression Profiles | varchar(255) | 110 | |
| 207 | hgram_cdf | attr_count | Gene attribute count | integer | int(11) | 2540 | |
| 208 | hgram_cdf | attr_cdf | Gene attribute CDF (cummulative distribution function) | 0.7703750883424460 | decimal(17,16) | 17059 | |
| 209 | homologgene | id | TCRD identifier for the HomoloGene data table | 1-69991 | int(11) | 69991 | |
| 210 | homologgene | protein_id | Foreign key to column id in table protein. | (null), or integer | int(11) | 18806 | |
| 211 | homologgene | nhprotein_id | Foreign key to column id in table nhprotein. | (null), or integer | int(11) | 51185 | |
| 212 | homologgene | groupid | Unique integer identifier for the HomoloGene group | integer | int(11) | 20932 | |
| 213 | homologgene | taxid | Taxonomic id for the highest taxonomic level of conservation for the group | 9606, 10090, 10116 | int(11) | 3 | |
| 214 | idg_evol | id | TCRD identifier for the idg_evol table, which keeps track of target evolution between major TCRD versions | 1-5118 | int(11) | 5118 | |
| 215 | idg_evol | tcrd_ver | | TRUE | tinyint(1) | 1 | |
| 216 | idg_evol | tcrd_dbid | | integer | int(11) | 3900 | |
| 217 | idg_evol | name | UniProt entry name | 5HT1A_HUMAN | varchar(255) | 1836 | |
| 218 | idg_evol | description | UniProt protein name | 5-hydroxytryptamine receptor 1A | text | 1848 | |
| 219 | idg_evol | uniprot | UniProt entry code | P08908 | varchar(20) | 1803 | |
| 220 | idg_evol | sym | Gene symbol | HTR1A | varchar(20) | 1814 | |
| 221 | idg_evol | geneid | HGNC gene id | integer | int(11) | 1806 | |
| 222 | idg_evol | tdl | IDG target development level | Tclin, Tchem, Tbio, Tdark | varchar(6) | 4 | |
| 223 | idg_evol | fam | IDG protein family | GPCR, IC, Kinase, NR, oGPCR | varchar(20) | 6 | |
| 224 | kegg_distance | id | TCRD identifier for kegg_distance table | 1-208238 | int(11) | 208238 | |
| 225 | kegg_distance | pid1 | Foreign key to column id in table protein. | integer | int(11) | 4323 | |
| 226 | kegg_distance | pid2 | Foreign key to column id in table protein. | integer | int(11) | 3071 | |
| 227 | kegg_distance | distance | Shortest path distance from KEGG Pathways between two proteins | integer | int(11) | 18 | |
| 228 | kegg_nearest_tclin | id | TCRD identifier for kegg_nearest_tclin table | integer | int(11) | 15911 | |
| 229 | kegg_nearest_tclin | protein_id | Foreign key to column id in table protein. | integer | int(11) | 2574 | |
| 230 | kegg_nearest_tclin | tclin_id | Foreign key to column id in table target | integer | int(11) | 403 | |
| 231 | kegg_nearest_tclin | direction | Direction to nearest Tclin target | upstream, downstream | enum('upstream','downstream') | 2 | |
| 232 | kegg_nearest_tclin | distance | Distance to neareast upstream and downstream Tclin from KEGG Pathways | integer | int(11) | 8 | |
| 233 | knex_migrations | id | | integer | int(10) unsigned | 19 | |
| 234 | knex_migrations | name | | 20201222234410_createIDGtable.ts | varchar(255) | 19 | |
| 235 | knex_migrations | batch | | integer | int(11) | 19 | |
| 236 | knex_migrations | migration_time | | 2021-01-22 22:41:48 | timestamp | 19 | |
| 237 | knex_migrations_lock | index | | 44 | int(10) unsigned | 1 | |
| 238 | knex_migrations_lock | is_locked | | 0 | int(11) | 1 | |
| 239 | lincs | id | TCRD identifier for the LINCS table | 1-84097720 | int(11) | 84097720 | |
| 240 | lincs | protein_id | Foreign key to column id in table protein. | integer | int(11) | 980 | |
| 241 | lincs | cellid | ATCC cell line | HELA | varchar(10) | 82 | |
| 242 | lincs | zscore | Z-score of the differential expression values for the specific gene | -0.436812 | decimal(8,6) | 7804415 | |
| 243 | lincs | pert_dcid | DrugCentral ID for perturbagen drug | integer | int(11) | 1613 | |
| 244 | lincs | pert_smiles | Chemical structure in SMILES format for perturbagen drug | OC(=O)CCc1nc(c(o1)-c1ccccc1)-c1ccccc1 | text | 2147 | |
| 245 | locsig | id | TCRD identifier for the LocSigDB table | 1-106521 | int(11) | 106521 | |
| 246 | locsig | protein_id | Foreign key to column id in table protein. | integer | int(11) | 18916 | |
| 247 | locsig | location | Cellular location of protein | Lysosome|Melanosome | varchar(255) | 14 | |
| 248 | locsig | signal | Generic structure of protein localization signal peptide | [DE]x{3}L[LI] | varchar(255) | 31 | |
| 249 | locsig | pmids | PubMed references | 19116314|16262729|19523115|18479248|17635580 | text | 239 | |
| 250 | mlp_assay_info | id | | | int(11) | 0 | Empty table? |
| 251 | mlp_assay_info | protein_id | Foreign key to column id in table protein. | | int(11) | 0 | |
| 252 | mlp_assay_info | assay_name | | | text | 0 | |
| 253 | mlp_assay_info | method | | | varchar(255) | 0 | |
| 254 | mlp_assay_info | active_sids | | | int(11) | 0 | |
| 255 | mlp_assay_info | inactive_sids | | | int(11) | 0 | |
| 256 | mlp_assay_info | iconclusive_sids | | | int(11) | 0 | |
| 257 | mlp_assay_info | total_sids | | | int(11) | 0 | |
| 258 | mlp_assay_info | aid | | | int(11) | 0 | |
| 259 | mpo | mpid | Mammalian Phenotype Ontology (MPO) term ID | MP:0000018 | | | |
| 260 | mpo | parent_id | MPO parent term ID | | | | |
| 261 | mpo | name | MPO term name | | | | |
| 262 | mpo | def | MPO term definition | | | | |
| 263 | nhprotein | id | TCRD identifier for the nhprotein table | 1- 121277 | int(11) | 121277 | |
| 264 | nhprotein | uniprot | UniProt entry ID | Q9CQA6 | varchar(20) | 121277 | |
| 265 | nhprotein | name | UniProt entry ID | CHCH1_MOUSE | varchar(255) | 121277 | |
| 266 | nhprotein | description | UniProt protein name | Coiled-coil-helix-coiled-coil-helix domain-containing protein 1 | text | 47393 | |
| 267 | nhprotein | sym | Gene symbol | Chchd1 | varchar(30) | 29381 | |
| 268 | nhprotein | species | Organism | Rattus norvegicus Mus musculus | varchar(40) | 2 | |
| 269 | nhprotein | taxid | UniProt taxonomy ID | 10090, 10116 | int(11) | 2 | |
| 270 | nhprotein | geneid | HGNC gene ID | 66121 | int(11) | 38094 | |
| 271 | omim | mim | Phenotype Mendelian Inheritance in Man (MIM) number | integer | int(11) | 26221 | |
| 272 | omim | title | Phenotype name | AARSKOG SYNDROME, AUTOSOMAL DOMINANT | varchar(255) | 25960 | |
| 273 | omim_ps | id | TCRD identifier for the omim_ps table | 1-4375 | int(11) | 4375 | |
| 274 | omim_ps | omim_ps_id | OMIM phenotypic series ID | PS100070 | char(8) | 450 | |
| 275 | omim_ps | mim | Foreign key to column mim in table omim. | 100070 | int(11) | 3628 | |
| 276 | omim_ps | title | Phenotypic series name | Aortic aneurysm, familial abdominal 1 | varchar(255) | 4232 | |
| 277 | ortholog | id | TCRD identifier for the HGNC Comparison of Orthology Predictions (HCOP) ortholog table | integer | int(11) | 178759 | |
| 278 | ortholog | protein_id | Foreign key to column id in table protein. | 1-18056 | int(11) | 18056 | |
| 279 | ortholog | taxid | UniProt taxonomy ID | integer | int(11) | 17 | |
| 280 | ortholog | species | Organism | Cow | varchar(255) | 17 | |
| 281 | ortholog | db_id | HCOP ortholog database ID | VGNC:27795 | varchar(255) | 113894 | |
| 282 | ortholog | geneid | HGNC gene ID | integer | int(11) | 169587 | |
| 283 | ortholog | symbol | Gene symbol | CTH | varchar(255) | 33498 | |
| 284 | ortholog | name | Human protein name | cystathionine gamma-lyase | varchar(255) | 49376 | |
| 285 | ortholog | mod_url | Model organism database URL | http://www.informatics.jax.org/marker/MGI:1339968 | text | 49093 | |
| 286 | ortholog | sources | Data sources | OMA, EggNOG Inparanoid, OMA, EggNOG Inparanoid, OMA Inparanoid, EggNOG | varchar(255) | 4 | |
| 287 | ortholog_disease | id | TCRD identifier for the ortholog-disease association table | 1-37852 | int(11) | 37852 | |
| 288 | ortholog_disease | protein_id | Foreign key to column id in table protein. | integer | int(11) | 3827 | |
| 289 | ortholog_disease | did | Disease ID | OMIM:125460 | varchar(255) | 5641 | |
| 290 | ortholog_disease | name | Disease name | Deoxyribose-5-Phosphate Aldolase Deficiency | varchar(255) | 5641 | |
| 291 | ortholog_disease | ortholog_id | Foreign key to column id in table ortholog. | integer | int(11) | 3827 | |
| 292 | ortholog_disease | score | Ortholog-disease association score | float | varchar(255) | 23678 | |
| 293 | p2pc | panther_class_id | Foreign key to column id in table panther_class. | integer | int(11) | 214 | |
| 294 | p2pc | protein_id | Foreign key to column id in table protein. | integer | int(11) | 8070 | |
| 295 | panther_class | id | | integer | int(11) | 256 | |
| 296 | panther_class | pcid | | PC00035 | char(7) | 256 | |
| 297 | panther_class | parent_pcids | | PC00084 | varchar(255) | 79 | |
| 298 | panther_class | name | | TGF-beta receptor | text | 256 | |
| 299 | panther_class | description | | | text | 0 | |
| 300 | patent_count | id | | integer | int(11) | 41280 | |
| 301 | patent_count | protein_id | Foreign key to column id in table protein. | integer | int(11) | 1710 | |
| 302 | patent_count | year | | 2016 | int(4) | 44 | |
| 303 | patent_count | count | | integer | int(11) | 4650 | |
| 304 | pathway | id | | 1-331936 | int(11) | 331936 | |
| 305 | pathway | target_id | Foreign key to column id in table target. | (null) | int(11) | 0 | |
| 306 | pathway | protein_id | Foreign key to column id in table protein. | integer | int(11) | 12984 | |
| 307 | pathway | pwtype | Foreign key to column name in table pathway_type. | KEGG, PathwayCommons: humancyc, PathwayCommons: inoh, PathwayCommons: netpath, PathwayCommons: panther, PathwayCommons: pid, Reactome, UniProt, WikiPathways | varchar(255) | 9 | |
| 308 | pathway | id_in_source | | path:hsa04151 | varchar(255) | 3109 | |
| 309 | pathway | name | | PI3K-Akt signaling pathway | text | 4516 | |
| 310 | pathway | description | | (null) | text | 0 | |
| 311 | pathway | url | | http://www.kegg.jp/kegg-bin/show_pathway?hsa04151 | text | 4323 | |
| 312 | pathway_type | name | | KEGG PathwayCommons: ctd PathwayCommons: humancyc PathwayCommons: inoh PathwayCommons: mirtarbase PathwayCommons: netpath PathwayCommons: panther PathwayCommons: pid PathwayCommons: recon PathwayCommons: smpdb PathwayCommons: transfac Reactome UniProt WikiPathways | varchar(255) | 14 | |
| 313 | pathway_type | url | | http://www.kegg.jp/kegg/pathway.html http://www.pathwaycommons.org/pc2/ctd http://www.pathwaycommons.org/pc2/humancyc http://www.pathwaycommons.org/pc2/inoh http://www.pathwaycommons.org/pc2/mirtarbase http://www.pathwaycommons.org/pc2/netpath http://pathwaycommons.org/pc2/panther http://www.pathwaycommons.org/pc2/pid http://www.pathwaycommons.org/pc2/recon http://www.pathwaycommons.org/pc2/smpdb http://www.pathwaycommons.org/pc2/transfac http://www.reactome.org/ http://www.uniprot.org/ http://www.wikipathways.org/index.php/WikiPathways | text | 14 | |
| 314 | phenotype | id | | integer | int(11) | 7318480 | |
| 315 | phenotype | ptype | Foreign key to column name in table phenotype_type. | IMPC, JAX/MGI Human Ortholog Phenotype, OMIM | varchar(255) | 3 | |
| 316 | phenotype | protein_id | Foreign key to column id in table protein. | integer | int(11) | 15397 | |
| 317 | phenotype | nhprotein_id | Foreign key to column id in table nhprotein. | integer | int(11) | 27637 | |
| 318 | phenotype | trait | | MIM integer: 103320; Phenotype: Myasthenic syndrome, congenital, 8, with pre- and postsynaptic defects, 615120 (3) | text | 13751 | |
| 319 | phenotype | top_level_term_id | | MP:0005378 | varchar(255) | 76 | |
| 320 | phenotype | top_level_term_name | | cardiovascular system phenotype | varchar(255) | 76 | |
| 321 | phenotype | term_id | | MP:0005386 | varchar(255) | 738 | |
| 322 | phenotype | term_name | | behavior/neurological phenotype | varchar(255) | 741 | |
| 323 | phenotype | term_description | | (null) | text | 0 | |
| 324 | phenotype | p_value | | float | double | 452786 | |
| 325 | phenotype | percentage_change | | -186.1220193 | varchar(255) | 7282 | |
| 326 | phenotype | effect_size | | float | varchar(255) | 11149 | |
| 327 | phenotype | procedure_name | | Intraperitoneal glucose tolerance test (IPGTT) | varchar(255) | 92 | |
| 328 | phenotype | parameter_name | | Fat mass | varchar(255) | 967 | |
| 329 | phenotype | gp_assoc | | boolean | tinyint(1) | 3 | |
| 330 | phenotype | statistical_method | | (null) Mixed Model framework, linear mixed-effects model, equation withoutWeight Mixed Model framework, generalized least squares, equation withWeight Mixed Model framework, generalized least squares, equation withoutWeight Mixed Model framework, linear mixed-effects model, equation withWeight Unknown Fisher Exact Test framework Supplied as data Not processed Manual | text | 10 | |
| 331 | phenotype | sex | | (null), female, male, no_data, both | varchar(8) | 5 | |
| 332 | phenotype_type | name | | GWAS Catalog IMPC JAX/MGI Human Ortholog Phenotype OMIM | varchar(255) | 4 | |
| 333 | phenotype_type | ontology | | (null) Mammalian Phenotype Ontology Mammalian Phenotype Ontology (null) | varchar(255) | 4 | |
| 334 | phenotype_type | description | | GWAS findings from NHGRI/EBI GWAS catalog file. Phenotypes from the International Mouse Phenotyping Consortium. These are single gene knockout phenotypes. JAX/MGI house/human orthology phenotypes in file HMD_HumanPhenotype.rpt from ftp.informatics.jax.or Phenotypes from OMIM with status Confirmed. phenotype.trait is a concatenation of Title, MIM integer, Method, and Comments fields from the OMIM genemap2.txt file. | text | 4 | |
| 335 | pmscore | id | | integer | int(11) | 384954 | |
| 336 | pmscore | protein_id | Foreign key to column id in table protein. | integer | int(11) | 17982 | |
| 337 | pmscore | year | | integer | int(4) | 119 | |
| 338 | pmscore | score | | float | decimal(12,6) | 168075 | |
| 339 | ppi | id | | integer | int(11) | 11735789 | |
| 340 | ppi | ppitype | Protein-protein interaction (PPI) type/source | BioPlex Reactome STRINGDB | varchar(255) | 3 | |
| 341 | ppi | protein1_id | Foreign key to column id in table protein. | integer | int(11) | 19113 | |
| 342 | ppi | protein1_str | | P62136|PPP1CA|5499 | varchar(255) | 28935 | |
| 343 | ppi | protein2_id | Foreign key to column id in table protein. | integer | int(11) | 19136 | |
| 344 | ppi | protein2_str | | Q9ULJ8|PPP1R9A|55607 | varchar(255) | 36977 | |
| 345 | ppi | p_int | | Q07021|C1QBP|708 | decimal(10,9) | 69661 | |
| 346 | ppi | p_ni | | float | decimal(10,9) | 68441 | |
| 347 | ppi | p_wrong | | float | decimal(10,9) | 18917 | |
| 348 | ppi | evidence | | 0 | varchar(255) | 0 | |
| 349 | ppi | interaction_type | | (null) | varchar(100) | 0 | |
| 350 | ppi | score | | integer | int(4) | 850 | |
| 351 | ppi_type | name | Protein-protein interaction (PPI) type/source | BioPlex Reactome | varchar(255) | 2 | |
| 352 | ppi_type | description | | The BioPlex (biophysical interactions of ORFeome-based complexes) network is the result of creating thousands of cell lines with each expressing a tagged version of a protein from the ORFeome collection. Interactions derived from Reactome pathways | text | 2 | |
| 353 | ppi_type | url | | http://wren.hms.harvard.edu/bioplex/ http://www.reactome.org/ | text | 2 | |
| 354 | protein | id | TCRD protein identifier | 1 - 20412 | int(11) | 20412 | |
| 355 | protein | name | UniProt entry name | CHERP_HUMAN | varchar(255) | 20412 | |
| 356 | protein | description | Uniprot recommended protein name | Calcium homeostasis endoplasmic reticulum protein | text | 20405 | |
| 357 | protein | uniprot | UniProt ID | Q8IWX8 | varchar(20) | 20412 | |
| 358 | protein | up_version | UniProt ID version | integer | int(11) | 8 | |
| 359 | protein | geneid | NCBI gene ID | integer | int(11) | 20011 | |
| 360 | protein | sym | Protein symbol | CHP1 | varchar(20) | 20080 | |
| 361 | protein | family | Uniprot family and domains information derived from sequence similarities | Belongs to the calcineurin regulatory subunit family. CHP subfamily. | varchar(255) | 5043 | |
| 362 | protein | chr | Chromosome | 19 | varchar(255) | 0 | |
| 363 | protein | seq | Protein sequence | MQEKDASSQGFLPHFQHFATQAIHVGQDPEQWTSRAVVPPISLSTTFKQGAPGQHSGFEYSRSGNPTRNCLEKAVAALDGAKYCLAFASGLAATVTITHLLKAGDQIICMDDVYGGTNRYFRQVASEFGLKISFVDCSKIKLLEAAITPETKLVWIETPTNPTQKVIDIEGCAHIVHKHGDIILVVDNTFMSPYFQRPLALGADISMYSATKYMNGHSDVVMGLVSVNCESLHNRLRFLQNSLGAVPSPIDCYLCNRGLKTLHVRMEKHFKNGMAVAQFLESNPWVEKVIYPGLPSHPQHELVKRQCTGCTGMVTFYIKGTLQHAEIFLKNLKLFTLAESLGGFESLAELPAIMTHASVLKNDRDVLGISDTLIRLSVGLEDEEDLLEDLDQALKAAHPPSGSHS | text | 20348 | |
| 364 | protein | dtoid | DTO ID | DTO_05004572 | varchar(13) | 9232 | |
| 365 | protein | stringid | Ensembl protein ID (as used by STRING-DB) | ENSP00000359976 | varchar(15) | 18960 | |
| 366 | protein | dtoclass | DTO class | Lyase | varchar(255) | 860 | |
| 367 | protein2pubmed | protein_id | Foreign key to column id in table protein. | integer | int(11) | 19790 | |
| 368 | protein2pubmed | pubmed_id | Foreign key to column id in table pubmed | integer | int(11) | 576647 | |
| 369 | provenance | | see datasets tab | | | | |
| 370 | ptscore | id | | integer | int(11) | 468019 | |
| 371 | ptscore | protein_id | Foreign key to column id in table protein. | integer | int(11) | 18310 | |
| 372 | ptscore | year | | integer | int(4) | 119 | |
| 373 | ptscore | score | | float | decimal(12,6) | 59549 | |
| 374 | pubmed | id | Article PubMed ID | integer | int(11) | 2746858 | |
| 375 | pubmed | title | Article title | Aflatoxin B1 metabolism to aflatoxicol and derivatives lethal to Bacillus subtilis GSY 1057 by rainbow trout (Salmo gairdneri) liver. | text | 2737912 | |
| 376 | pubmed | journal | Article journal | Cancer research | text | 12234 | |
| 377 | pubmed | date | Article publication date | 1976-06 | varchar(10) | 18197 | |
| 378 | pubmed | authors | Article authors | Schoenhard, G L GL and 5 more authors. | text | 2423527 | |
| 379 | pubmed | abstract | Article authors | Aflatoxicol, R0, was isolated from Mt. Shasta strain rainbow trout (Salmo gairdneri), and liver homogenates were incubated with aflatoxin B1. Its identity was confirmed by mass, infrared, and ultraviolet spectrometry. The structure was identical to one of the diastereomers prepared by chemical reduction of aflatoxin B1. Aflatoxicol was apparently formed by a reduced nicotinamide adenine dinucleotide phosphate-dependent soluble enzyme of the 105,000 x g supernatant from rainbow trout. Aflatoxicol was not lethal in phosphate buffer to Bacillus subtilis GSY 1057 (metB4, hisA1, uvr-1) nor were aflatoxins B1, Q1, and B2. In the presence of reduced nicotinamide adenine dinucleotide phosphate and trout liver microsomes, aflatoxicol reduced the viability of B. subtilis. Aflatoxin B2, which lacks the vinyl ether present in the other compounds, could not be activated. The product of aflatoxin B1 activation by trout liver microsomes was sought after incubation of 14C-labeled aflatoxin B1. The radioactivity was found in unaltered aflatoxin B1 and in three extremely polar metabolites. The quantity of the new metabolites and the level of microbial lethality was reduced by addition of cytosine and cysteine to the incubation medium. The vinyl ether configuration was a structural requirement for activation, and this finding and the nature of the enzymatic reaction were consistent with the hypothesis that the compounds were metabolized to highly reactive and unstable electrophilic products which bound to nucleophiles such as cytosine and were lethal to B. subtilis. The formation of aflatoxicol as the major product of trout liver metabolism is of great significance considering that it could be activated to a lethal compound and that rainbow trout are one of the most sensitive species to aflatoxin B1-induced carcinoma. | text | 2666654 | |
| 380 | rat_qtl | id | | integer | int(11) | 1799 | |
| 381 | rat_qtl | nhprotein_id | Foreign key to column id in table nhprotein. | integer | int(11) | 908 | |
| 382 | rat_qtl | rgdid | | integer | int(11) | 502 | |
| 383 | rat_qtl | qtl_rgdid | | integer | int(11) | 301 | |
| 384 | rat_qtl | qtl_symbol | | Plsm2 | varchar(10) | 301 | |
| 385 | rat_qtl | qtl_name | | Polydactyly-luxate syndrome (PLS) morphotypes QTL 2 | varchar(255) | 301 | |
| 386 | rat_qtl | trait_name | | hindlimb integrity trait (VT:0010563) | varchar(255) | 74 | |
| 387 | rat_qtl | measurement_type | | hind foot phalanges count (CMO:0001949) | varchar(255) | 109 | |
| 388 | rat_qtl | associated_disease | | polydactyly | varchar(255) | 82 | |
| 389 | rat_qtl | phenotype | | polydactyly | varchar(255) | 126 | |
| 390 | rat_qtl | p_value | | float | decimal(20,19) | 44 | |
| 391 | rat_qtl | lod | | float | float(6,3) | 114 | |
| 392 | rat_term | id | | integer | int(11) | 117602 | |
| 393 | rat_term | rgdid | | integer | int(11) | 10127 | |
| 394 | rat_term | term_id | | DOID:1612 | varchar(20) | 11332 | |
| 395 | rat_term | obj_symbol | | Six1 | varchar(20) | 10127 | |
| 396 | rat_term | term_name | | breast cancer | varchar(255) | 10058 | |
| 397 | rat_term | qualifier | | severity | varchar(20) | 11 | |
| 398 | rat_term | evidence | | ISS | varchar(5) | 12 | |
| 399 | rat_term | ontology | | Disease Ontology, Mammalian Phenotype, RGD Disease Ontology | varchar(40) | 3 | |
| 400 | rdo | doid | | DOID:0001816 | varchar(12) | 18085 | |
| 401 | rdo | name | | angiosarcoma | text | 18085 | |
| 402 | rdo | def | | A rare malignant neoplasm characterized by rapidly proliferating, extensively infiltrating, anaplastic cells derived from blood vessels and lining irregular blood-filled or lumpy spaces. (Stedman, 25th ed) | text | 10034 | |
| 403 | rdo_xref | doid | Foreign key to column doid in table rdo. | DOID:9009161 | varchar(12) | 17318 | |
| 404 | rdo_xref | db | | DOID | varchar(24) | 10 | |
| 405 | rdo_xref | value | | number | varchar(24) | 38831 | |
| 406 | resolver_output | id | | integer | int(10) unsigned | 3097 | |
| 407 | resolver_output | input | | alcaftadine | text | 3097 | |
| 408 | resolver_output | smilesParent | | CN1CCC(CC1)=C2C3=NC=C(C=O)N3CCC4=C2C=CC=C4 | text | 2000 | |
| 409 | resolver_output | pt | | ALCAFTADINE | varchar(255) | 1788 | |
| 410 | resolver_output | unii | | 7Z8O94ECSX | varchar(12) | 1704 | |
| 411 | resolver_output | smiles | | CN1CCC(CC1)=C2C3=NC=C(C=O)N3CCC4=C2C=CC=C4 | text | 2033 | |
| 412 | resolver_output | lychi | | S4GHBD1FU-UDYRYTP1VB-UBC734PAGQ9-UB9SA8WABQD2 | varchar(50) | 1528 | |
| 413 | resolver_output | lychi_h4 | | UB9SA8WABQD2 | varchar(15) | 1528 | |
| 414 | resolver_output | cas | | 147084-10-4 | varchar(255) | 1787 | |
| 415 | resolver_output | method | | FDA-SRS null (null) smiles | varchar(255) | 3 | |
| 416 | resolver_output | url | | http://fdasis.nlm.nih.gov/srs/srsdirect.jsp?regno=7Z8O94ECSX | varchar(255) | 1437 | |
| 417 | sequence_annotation | id | | integer | int(10) unsigned | 32519 | |
| 418 | sequence_annotation | dataSource | | ProKinO | varchar(255) | 1 | |
| 419 | sequence_annotation | protein_id | | integer | int(11) | 472 | |
| 420 | sequence_annotation | residue_start | | integer | int(11) | 1883 | |
| 421 | sequence_annotation | residue_end | | integer | int(11) | 2000 | |
| 422 | sequence_annotation | type | | Glycine Loop | enum('Activation Loop','Activation Segment','alphaC-beta4 Loop','CMGC Insert','Gatekeeper','Linker','KeyAA','Motif','beta-strand','alpha-helix','C-Lobe','C-Spine','RD Pocket','Catalytic Loop','Glycine Loop','N-Lobe','R-Spine','R-Spine Shell','Subdomain') | 19 | |
| 423 | sequence_annotation | name | | glycine-rich loop | varchar(255) | 70 | |
| 424 | sequence_variant | id | | integer | int(10) unsigned | 1063403 | |
| 425 | sequence_variant | dataSource | | ProKinO | varchar(255) | 1 | |
| 426 | sequence_variant | protein_id | | integer | int(11) | 543 | |
| 427 | sequence_variant | residue | | integer | int(11) | 34350 | |
| 428 | sequence_variant | variant | | amino acid letter | varchar(1) | 20 | |
| 429 | sequence_variant | bits | | float | float(12,11) | 785801 | |
| 430 | t2tc | target_id | Foreign key to column id in table target. | integer | int(11) | 20412 | |
| 431 | t2tc | protein_id | Foreign key to column id in table protein. | integer | int(11) | 20412 | |
| 432 | t2tc | nucleic_acid_id | Foreign key to the (future) nucleic_acid table | (null) | int(11) | 0 | |
| 433 | target | id | TCRD target identifier | integer | int(11) | 20412 | Generated for each new version of TCRD. |
| 434 | target | name | Target name | Calmodulin-binding transcription activator 2 | varchar(255) | 20405 | |
| 435 | target | ttype | Reserved for future use - now only Single Protein | Single Protein | varchar(255) | 1 | |
| 436 | target | description | Empty (reserved for future use) | (null) | text | 0 | |
| 437 | target | comment | Empty (reserved for future use) | (null) | text | 0 | |
| 438 | target | tdl | Target development level, as defined at http://juniper.health.unm.edu/tcrd/ | Tbio, Tclin, Tdark, Tchem | enum('Tclin','Tchem','Tbio','Tdark') | 4 | |
| 439 | target | idg | Flag to mark if protein is on the IDG understudied proteins list (1) or not (0) | boolean | tinyint(1) | 2 | |
| 440 | target | fam | Major target family | Enzyme, GPCR, IC, Kinase, NR, TF | enum('Enzyme','Epigenetic','GPCR','IC','Kinase','NR','oGPCR','TF','TF; Epigenetic','Transporter') | 10 | |
| 441 | target | famext | Target family | phosphatase, GTPase, peptidase | varchar(255) | 139 | |
| 442 | tdl_info | id | | integer | int(11) | 241680 | |
| 443 | tdl_info | itype | Foreign key to column name in table info_type. | UniProt Function | varchar(255) | 19 | |
| 444 | tdl_info | target_id | Foreign key to column id in table target. | integer | int(11) | 1791 | |
| 445 | tdl_info | protein_id | Foreign key to column id in table protein. | integer | int(11) | 20412 | |
| 446 | tdl_info | nucleic_acid_id | | (null) | int(11) | 0 | |
| 447 | tdl_info | string_value | | Catalyzes the last step in the trans-sulfuration pathway from methionine to cysteine. Has broad substrate specificity. Converts cystathionine to cysteine, ammonia and 2-oxobutanoate. Converts two cysteine molecules to lanthionine and hydrogen sulfide. Can also accept homocysteine as substrate. Specificity depends on the levels of the endogenous substrates. Generates the endogenous signaling molecule hydrogen sulfide (H2S), and so contributes to the regulation of blood pressure. Acts as a cysteine-protein sulfhydrase by mediating sulfhydration of target proteins: sulfhydration consists of converting -SH groups into -SSH on specific cysteine residues of target proteins such as GAPDH, PTPN1 and NF-kappa-B subunit RELA, thereby regulating their function. | text | 58520 | |
| 448 | tdl_info | integer_value | | float | decimal(12,6) | 32867 | |
| 449 | tdl_info | integer_value | | integer | int(11) | 2609 | |
| 450 | tdl_info | date_value | | date | date | 0 | |
| 451 | tdl_info | boolean_value | | boolean | tinyint(1) | 1 | |
| 452 | tdl_info | curration_level | | (cull) | varchar(50) | 0 | |
| 453 | tdl_update_log | id | | | int(11) | 0 | |
| 454 | tdl_update_log | target_id | | | int(11) | 0 | |
| 455 | tdl_update_log | old_tdl | | | varchar(10) | 0 | |
| 456 | tdl_update_log | new_tdl | | | varchar(10) | 0 | |
| 457 | tdl_update_log | person | | | varchar(255) | 0 | |
| 458 | tdl_update_log | datetime | | | timestamp | 0 | |
| 459 | tdl_update_log | explanation | | | text | 0 | |
| 460 | tdl_update_log | application | | | varchar(255) | 0 | |
| 461 | tdl_update_log | app_version | | | varchar(255) | 0 | |
| 462 | techdev_contact | id | | | int(11) | 0 | |
| 463 | techdev_contact | contact_name | | | varchar(255) | 0 | |
| 464 | techdev_contact | contact_email | | | varchar(255) | 0 | |
| 465 | techdev_contact | date | | | date | 0 | |
| 466 | techdev_contact | grant_integer | | | varchar(255) | 0 | |
| 467 | techdev_contact | pi | | | varchar(255) | 0 | |
| 468 | techdev_info | id | | | int(11) | 0 | |
| 469 | techdev_info | contact_id | Foreign key to column id in table techdev_contact. | | int(11) | 0 | |
| 470 | techdev_info | protein_id | Foreign key to column id in table protein. | | int(11) | 0 | |
| 471 | techdev_info | comment | | | text | 0 | |
| 472 | techdev_info | publication_pcmid | | | varchar(255) | 0 | |
| 473 | techdev_info | publication_pmid | | | int(11) | 0 | |
| 474 | techdev_info | resource_url | | | text | 0 | |
| 475 | techdev_info | data_url | | | text | 0 | |
| 476 | tiga | id | TCRD TIGA association ID | integer | int(11) | 102407 | |
| 477 | tiga | protein_id | Foreign key to column id in table protein. | integer | int(11) | 11765 | |
| 478 | tiga | ensg | Ensembl gene ID | ENSG00000000460 | varchar(15) | 11761 | |
| 479 | tiga | efoid | EFO ID (trait ID) | EFO_0006937 | varchar(15) | 1441 | |
| 480 | tiga | trait | Trait name (from EFO) | optic disc area measurement | varchar(255) | 1441 | |
| 481 | tiga | n_study | Number of studies for this gene-trait association | integer | int(2) | 38 | |
| 482 | tiga | n_snp | Number of SNPs for this gene-trait association | integer | int(2) | 56 | |
| 483 | tiga | n_snpw | Number of SNPs for this gene-trait pair, weighted by SNP-gene distance | float | decimal(5,3) | 3170 | |
| 484 | tiga | geneNtrait | Number of traits associated with this gene | integer | int(2) | 91 | |
| 485 | tiga | geneNstudy | Number of studies associated with this gene | integer | int(2) | 139 | |
| 486 | tiga | traitNgene | Number of genes associated with this trait | integer | int(2) | 269 | |
| 487 | tiga | traitNstudy | Number of studies associated with this trait | integer | int(2) | 64 | |
| 488 | tiga | pvalue_mlog_median | median(-log(pvalue)) | float | decimal(6,3) | 2129 | |
| 489 | tiga | or_median | median(OR) | float | decimal(8,3) | 2679 | |
| 490 | tiga | n_beta | Number of beta values for this gene-trait association | integer | int(2) | 92 | |
| 491 | tiga | study_N_mean | mean(N) for studies supporting this association | integer | int(2) | 7938 | |
| 492 | tiga | rcras | Relative Citation Ratio Aggregate Score | float | decimal(5,3) | 2429 | |
| 493 | tiga | meanRank | mean rank for selected gene-trait association variables (see TIGA documentation for list) | float | decimal(18,12) | 21932 | |
| 494 | tiga | meanRankScore | 100 - percentile(meanRank) | float | decimal(18,14) | 21932 | |
| 495 | tiga_provenance | id | TCRD TIGA provenance ID | integer | int(11) | 167811 | |
| 496 | tiga_provenance | ensg | Ensembl gene ID | ENSG00000000971 | varchar(15) | 12158 | |
| 497 | tiga_provenance | efoid | EFO ID (trait ID) | EFO_0001365 | varchar(15) | 1452 | |
| 498 | tiga_provenance | study_acc | GWAS Catalog study accession | GCST001100 | varchar(20) | 3930 | |
| 499 | tiga_provenance | pubmedid | PubMed ID | 21665990 | int(11) | 2500 | |
| 500 | tinx_articlerank | id | | integer | int(11) | 53609232 | |
| 501 | tinx_articlerank | importance_id | | integer | int(11) | 3015526 | |
| 502 | tinx_articlerank | pmid | Article PubMed ID | integer | int(11) | 2505076 | |
| 503 | tinx_articlerank | rank | | integer | int(11) | 143637 | |
| 504 | tinx_disease | id | TIN-X disease ID | integer | int(11) | 7604 | |
| 505 | tinx_disease | doid | Disease DOID | DOID:3121 | varchar(20) | 7604 | |
| 506 | tinx_disease | name | Disease name | gallbladder cancer | text | 7604 | |
| 507 | tinx_disease | summary | Disease summary | A biliary tract cancer that is located_in the gallbladder. | text | 5065 | |
| 508 | tinx_disease | score | TIN-X disease novelty score (Cannon et al., 2017) | float | decimal(34,16) | 6848 | |
| 509 | tinx_importance | doid | Foreign key to column doid in table tinx_disease. | integer | int(11) | 3015526 | |
| 510 | tinx_importance | protein_id | Foreign key to column id in table protein. | integer | int(11) | 17425 | |
| 511 | tinx_importance | disease_id | TIN-X disease ID | integer | int(11) | 6778 | |
| 512 | tinx_importance | score | TIN-X importance score (Cannon et al., 2017) | float | decimal(34,16) | 660313 | |
| 513 | tinx_novelty | id | | integer | int(11) | 18032 | |
| 514 | tinx_novelty | protein_id | TCRD protein ID | integer | int(11) | 18032 | |
| 515 | tinx_novelty | score | TIN-X target novelty score (Cannon et al., 2017) | float | decimal(34,16) | 15420 | |
| 516 | uberon | uid | | CHEBI:138675 | varchar(20) | 18117 | |
| 517 | uberon | name | | gas molecular entity | text | 18113 | |
| 518 | uberon | def | | Any of the passages admitting nutrient vessels to the medullary cavity of bone | text | 12779 | |
| 519 | uberon | comment | | A prepollex does not contain phalanges nor does it articulate with a metacarpal. It articulates with elements of the carpal (wrist) skeleton[AAO:DB]. editor note: TODO add articulation relations | text | 1068 | |
| 520 | uberon_parent | uid | Foreign key to column uid in table uberon. | UBERON:0003531 | varchar(20) | 18107 | |
| 521 | uberon_parent | parent_id | | UBERON:0001419 | varchar(20) | 5747 | |
| 522 | uberon_xref | uid | Foreign key to column uid in table uberon. | CL:0000000 | varchar(20) | 10934 | |
| 523 | uberon_xref | db | | GO | varchar(24) | 69 | |
| 524 | uberon_xref | value | | integer | varchar(255) | 24122 | |
| 525 | viral_ppi | id | | integer | int(11) | 282528 | |
| 526 | viral_ppi | viral_protein_id | Foreign key to column id in table viral_protein. | integer | int(11) | 7463 | |
| 527 | viral_ppi | protein_id | Foreign key to column id in table protein. | integer | int(11) | 5719 | |
| 528 | viral_ppi | dataSource | | P-HIPSTer | varchar(20) | 1 | |
| 529 | viral_ppi | finalLR | | float | decimal(20,12) | 2170 | |
| 530 | viral_ppi | pdbIDs | | | varchar(128) | 44 | |
| 531 | viral_ppi | highConfidence | | 0,1 | tinyint(4) | 2 | |
| 532 | viral_protein | id | | integer | int(11) | 12499 | |
| 533 | viral_protein | name | | full_polyprotein 1..2119 | varchar(128) | 5020 | |
| 534 | viral_protein | ncbi | | YP_009112712.1 | varchar(128) | 9709 | |
| 535 | viral_protein | virus_id | Foreign key to column virusTaxid in table virus. | 1582094 | varchar(16) | 990 | |
| 536 | virus | virusTaxid | | integer | varchar(16) | 1001 | |
| 537 | virus | nucleic1 | | DNA,RNA, Retro | varchar(128) | 2 | |
| 538 | virus | nucleic2 | | (+)ssRNA dsDNA retro-DNA (-)ssRNA ssDNA dsRNA retro-RNA | varchar(128) | 7 | |
| 539 | virus | order | | Mononegavirales | varchar(128) | | |
| 540 | virus | family | | Rhabdoviridae | varchar(128) | 28 | |
| 541 | virus | subfamily | | | varchar(128) | 11 | |
| 542 | virus | genus | | Lyssavirus | varchar(128) | 78 | |
| 543 | virus | species | | Gammapapillomavirus 7 | varchar(128) | 212 | |
| 544 | virus | name | | Human papillomavirus type 109 | varchar(128) | 1001 | |
| 545 | xref | id | | integer | int(11) | 2600228 | |
| 546 | xref | xtype | Foreign key to column name in table xref_type | UniProt Keyword | varchar(255) | 21 | |
| 547 | xref | target_id | Foreign key to column id in table target | (null) | int(11) | 0 | |
| 548 | xref | protein_id | Foreign key to column id in table protein. | integer | int(11) | 20412 | |
| 549 | xref | nucleic_acid_id | | (null) | int(11) | 0 | |
| 550 | xref | value | | KW-0677 | varchar(255) | 1458974 | |
| 551 | xref | xtra | | Repeat | varchar(255) | 25703 | |
| 552 | xref | dataset_id | Foreign key to column id in table dataset. | integer | int(11) | 7 | |
| 553 | xref | nhprotein_id | Foreign key to column id in table nhprotein. | integer | int(11) | 86258 | |
| 554 | xref_type | name | | L1000 ID | varchar(255) | 21 | |
| 555 | xref_type | description | | CMap landmark gene ID. See http://support.lincscloud.org/hc/en-us/articles/202092616-The-Landmark-Genes | text | 6 | |
| 556 | xref_type | url | | (null) | text | 0 | |
| 557 | xref_type | eg_q_url | | (null) | text | 0 | |