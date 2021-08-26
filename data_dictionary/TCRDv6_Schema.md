# TCRD v6 Schema documentation

## Table: `alias`

### Description: 

### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `type` | ENUM | Not null |   |   |
| `value` | VARCHAR(255) | Not null |   |   |
| `dataset_id` | INT | Not null |   |  **foreign key** to column `id` on table `dataset`. |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| alias_idx1 | `protein_id` | INDEX |   |
| alias_idx2 | `dataset_id` | INDEX |   |


## Table: `clinvar`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `clinvar_phenotype_id` | INT | Not null |   |  **foreign key** to column `id` on table `clinvar_phenotype`. |
| `alleleid` | INT | Not null |   |   |
| `type` | VARCHAR(40) | Not null |   |   |
| `name` | TEXT | Not null |   |   |
| `review_status` | VARCHAR(60) | Not null |   |   |
| `clinical_significance` | VARCHAR(80) |  | `NULL` |   |
| `clin_sig_simple` | INT |  | `NULL` |   |
| `last_evaluated` | DATE |  | `NULL` |   |
| `dbsnp_rs` | INT |  | `NULL` |   |
| `dbvarid` | VARCHAR(10) |  | `NULL` |   |
| `origin` | VARCHAR(60) |  | `NULL` |   |
| `origin_simple` | VARCHAR(20) |  | `NULL` |   |
| `assembly` | VARCHAR(8) |  | `NULL` |   |
| `chr` | VARCHAR(2) |  | `NULL` |   |
| `chr_acc` | VARCHAR(20) |  | `NULL` |   |
| `start` | INT |  | `NULL` |   |
| `stop` | INT |  | `NULL` |   |
| `number_submitters` | INT |  | `NULL` |   |
| `tested_in_gtr` | TINYINT |  | `NULL` |   |
| `submitter_categories` | TINYINT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| clinvar_idx1 | `protein_id` | INDEX |   |
| clinvar_idx2 | `clinvar_phenotype_id` | INDEX |   |


## Table: `clinvar_phenotype`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `name` | VARCHAR(255) | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |


## Table: `clinvar_phenotype_xref`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `clinvar_phenotype_id` | INT | Not null |   |  **foreign key** to column `id` on table `clinvar_phenotype`. |
| `source` | VARCHAR(40) | Not null |   |   |
| `value` | VARCHAR(20) | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| clinvar_phenotype_idx1 | `clinvar_phenotype_id` | INDEX |   |


## Table: `cmpd_activity`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `target_id` | INT |  | `NULL` |  **foreign key** to column `id` on table `target`. |
| `catype` | VARCHAR(255) | Not null |   |  **foreign key** to column `name` on table `cmpd_activity_type`. |
| `cmpd_id_in_src` | VARCHAR(255) | Not null |   |   |
| `cmpd_name_in_src` | TEXT |  | `NULL` |   |
| `smiles` | TEXT |  | `NULL` |   |
| `act_value` | DECIMAL |  | `NULL` |   |
| `act_type` | VARCHAR(255) |  | `NULL` |   |
| `reference` | TEXT |  | `NULL` |   |
| `pubmed_ids` | TEXT |  | `NULL` |   |
| `cmpd_pubchem_cid` | INT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| cmpd_activity_idx1 | `catype` | INDEX |   |
| cmpd_activity_idx2 | `target_id` | INDEX |   |


## Table: `cmpd_activity_type`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `name` | VARCHAR(255) | PRIMARY, Not null |   |   |
| `description` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `name` | PRIMARY |   |


## Table: `compartment`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `ctype` | VARCHAR(255) | Not null |   |  **foreign key** to column `name` on table `compartment_type`. |
| `target_id` | INT |  | `NULL` |  **foreign key** to column `id` on table `target`. |
| `protein_id` | INT |  | `NULL` |  **foreign key** to column `id` on table `protein`. |
| `go_id` | VARCHAR(255) |  | `NULL` |   |
| `go_term` | TEXT |  | `NULL` |   |
| `evidence` | VARCHAR(255) |  | `NULL` |   |
| `zscore` | DECIMAL |  | `NULL` |   |
| `conf` | DECIMAL |  | `NULL` |   |
| `url` | TEXT |  | `NULL` |   |
| `reliability` | ENUM |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| compartment_idx1 | `ctype` | INDEX |   |
| compartment_idx2 | `target_id` | INDEX |   |
| compartment_idx3 | `protein_id` | INDEX |   |


## Table: `compartment_type`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `name` | VARCHAR(255) | PRIMARY, Not null |   |   |
| `description` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `name` | PRIMARY |   |


## Table: `data_type`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `name` | VARCHAR(7) | PRIMARY, Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `name` | PRIMARY |   |


## Table: `dataset`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `name` | VARCHAR(255) | Not null |   |   |
| `source` | TEXT | Not null |   |   |
| `app` | VARCHAR(255) |  | `NULL` |   |
| `app_version` | VARCHAR(255) |  | `NULL` |   |
| `datetime` | TIMESTAMP | Not null | `CURRENT_TIMESTAMP` |   |
| `url` | TEXT |  | `NULL` |   |
| `comments` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |


## Table: `dbinfo`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `dbname` | VARCHAR(16) | Not null |   |   |
| `schema_ver` | VARCHAR(16) | Not null |   |   |
| `data_ver` | VARCHAR(16) | Not null |   |   |
| `owner` | VARCHAR(16) | Not null |   |   |
| `is_copy` | TINYINT | Not null | `'0'` |   |
| `dump_file` | VARCHAR(64) |  | `NULL` |   |




## Table: `disease`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `dtype` | VARCHAR(255) | Not null |   |  **foreign key** to column `name` on table `disease_type`. |
| `protein_id` | INT |  | `NULL` |  **foreign key** to column `id` on table `protein`. |
| `nhprotein_id` | INT |  | `NULL` |  **foreign key** to column `id` on table `nhprotein`. |
| `name` | TEXT | Not null |   |   |
| `did` | VARCHAR(20) |  | `NULL` |   |
| `evidence` | TEXT |  | `NULL` |   |
| `zscore` | DECIMAL |  | `NULL` |   |
| `conf` | DECIMAL |  | `NULL` |   |
| `description` | TEXT |  | `NULL` |   |
| `reference` | VARCHAR(255) |  | `NULL` |   |
| `drug_name` | TEXT |  | `NULL` |   |
| `log2foldchange` | DECIMAL |  | `NULL` |   |
| `pvalue` | VARCHAR(255) |  | `NULL` |   |
| `score` | DECIMAL |  | `NULL` |   |
| `source` | VARCHAR(255) |  | `NULL` |   |
| `O2S` | DECIMAL |  | `NULL` |   |
| `S2O` | DECIMAL |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| disease_idx1 | `dtype` | INDEX |   |
| disease_idx2 | `protein_id` | INDEX |   |
| disease_idx3 | `nhprotein_id` | INDEX |   |


## Table: `disease_type`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `name` | VARCHAR(255) | PRIMARY, Not null |   |   |
| `description` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `name` | PRIMARY |   |


## Table: `do`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `doid` | VARCHAR(12) | PRIMARY, Not null |   |   |
| `name` | TEXT | Not null |   |   |
| `def` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `doid` | PRIMARY |   |


## Table: `do_parent`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `doid` | VARCHAR(12) | Not null |   |  **foreign key** to column `doid` on table `do`. |
| `parent_id` | VARCHAR(12) | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| fk_do_parent__do | `doid` | INDEX |   |


## Table: `do_xref`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `doid` | VARCHAR(12) | PRIMARY, Not null |   |  **foreign key** to column `doid` on table `do`. |
| `db` | VARCHAR(24) | PRIMARY, Not null |   |   |
| `value` | VARCHAR(24) | PRIMARY, Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `doid`, `db`, `value` | PRIMARY |   |
| do_xref__idx2 | `db`, `value` | INDEX |   |


## Table: `drgc_resource`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `rssid` | TEXT | Not null |   |   |
| `resource_type` | VARCHAR(255) | Not null |   |   |
| `target_id` | INT | Not null |   |  **foreign key** to column `id` on table `target`. |
| `json` | TEXT | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| drgc_resource_idx1 | `target_id` | INDEX |   |


## Table: `drug_activity`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `target_id` | INT | Not null |   |  **foreign key** to column `id` on table `target`. |
| `drug` | VARCHAR(255) | Not null |   |   |
| `act_value` | DECIMAL |  | `NULL` |   |
| `act_type` | VARCHAR(255) |  | `NULL` |   |
| `action_type` | VARCHAR(255) |  | `NULL` |   |
| `has_moa` | TINYINT | Not null |   |   |
| `source` | VARCHAR(255) |  | `NULL` |   |
| `reference` | TEXT |  | `NULL` |   |
| `smiles` | TEXT |  | `NULL` |   |
| `cmpd_chemblid` | VARCHAR(255) |  | `NULL` |   |
| `nlm_drug_info` | TEXT |  | `NULL` |   |
| `cmpd_pubchem_cid` | INT |  | `NULL` |   |
| `dcid` | INT | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| drug_activity_idx1 | `target_id` | INDEX |   |


## Table: `dto`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `dtoid` | VARCHAR(255) | PRIMARY, Not null |   |   |
| `name` | TEXT | Not null |   |   |
| `parent_id` | VARCHAR(255) |  | `NULL` |   |
| `def` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `dtoid` | PRIMARY |   |
| dto_idx1 | `parent_id` | INDEX |   |


## Table: `expression`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `etype` | VARCHAR(255) | Not null |   |  **foreign key** to column `name` on table `expression_type`. |
| `target_id` | INT |  | `NULL` |  **foreign key** to column `id` on table `target`. |
| `protein_id` | INT |  | `NULL` |  **foreign key** to column `id` on table `protein`. |
| `tissue` | TEXT | Not null |   |   |
| `qual_value` | ENUM |  | `NULL` |   |
| `number_value` | DECIMAL |  | `NULL` |   |
| `boolean_value` | TINYINT |  | `NULL` |   |
| `string_value` | TEXT |  | `NULL` |   |
| `pubmed_id` | INT |  | `NULL` |   |
| `evidence` | VARCHAR(255) |  | `NULL` |   |
| `zscore` | DECIMAL |  | `NULL` |   |
| `conf` | DECIMAL |  | `NULL` |   |
| `oid` | VARCHAR(20) |  | `NULL` |   |
| `confidence` | TINYINT |  | `NULL` |   |
| `url` | TEXT |  | `NULL` |   |
| `cell_id` | VARCHAR(20) |  | `NULL` |   |
| `uberon_id` | VARCHAR(20) |  | `NULL` |  **foreign key** to column `uid` on table `uberon`. |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| expression_idx1 | `etype` | INDEX |   |
| expression_idx2 | `target_id` | INDEX |   |
| expression_idx3 | `protein_id` | INDEX |   |
| fk_expression_uberon | `uberon_id` | INDEX |   |


## Table: `expression_type`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `name` | VARCHAR(255) | PRIMARY, Not null, Unique |   |   |
| `data_type` | VARCHAR(7) | Not null, Unique |   |  **foreign key** to column `name` on table `data_type`. |
| `description` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `name` | PRIMARY |   |
| expression_type_idx1 | `name`, `data_type` | UNIQUE |   |
| fk_expression_type__data_type | `data_type` | INDEX |   |


## Table: `extlink`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `source` | ENUM | Not null |   |   |
| `url` | TEXT | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| extlink_idx1 | `protein_id` | INDEX |   |


## Table: `feature`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `type` | VARCHAR(255) | Not null |   |   |
| `description` | TEXT |  | `NULL` |   |
| `srcid` | VARCHAR(255) |  | `NULL` |   |
| `evidence` | VARCHAR(255) |  | `NULL` |   |
| `begin` | INT |  | `NULL` |   |
| `end` | INT |  | `NULL` |   |
| `position` | INT |  | `NULL` |   |
| `original` | VARCHAR(255) |  | `NULL` |   |
| `variation` | VARCHAR(255) |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| feature_idx1 | `protein_id` | INDEX |   |


## Table: `gene_attribute`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `gat_id` | INT | Not null |   |  **foreign key** to column `id` on table `gene_attribute_type`. |
| `name` | TEXT | Not null |   |   |
| `value` | INT | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| gene_attribute_idx1 | `protein_id` | INDEX |   |
| gene_attribute_idx2 | `gat_id` | INDEX |   |


## Table: `gene_attribute_type`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `name` | VARCHAR(255) | Not null, Unique |   |   |
| `association` | TEXT | Not null |   |   |
| `description` | TEXT | Not null |   |   |
| `resource_group` | ENUM | Not null |   |   |
| `measurement` | VARCHAR(255) | Not null |   |   |
| `attribute_group` | VARCHAR(255) | Not null |   |   |
| `attribute_type` | VARCHAR(255) | Not null |   |   |
| `pubmed_ids` | TEXT |  | `NULL` |   |
| `url` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| gene_attribute_type_idx1 | `name` | UNIQUE |   |


## Table: `generif`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `pubmed_ids` | TEXT |  | `NULL` |   |
| `text` | TEXT | Not null |   |   |
| `years` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| generif_idx1 | `protein_id` | INDEX |   |


## Table: `goa`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `go_id` | VARCHAR(255) | Not null |   |   |
| `go_term` | TEXT |  | `NULL` |   |
| `evidence` | TEXT |  | `NULL` |   |
| `goeco` | VARCHAR(255) | Not null |   |   |
| `assigned_by` | VARCHAR(50) |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| goa_idx1 | `protein_id` | INDEX |   |


## Table: `gtex`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT |  | `NULL` |  **foreign key** to column `id` on table `protein`. |
| `tissue` | TEXT | Not null |   |   |
| `gender` | ENUM | Not null |   |   |
| `tpm` | DECIMAL | Not null |   |   |
| `tpm_rank` | DECIMAL |  | `NULL` |   |
| `tpm_rank_bysex` | DECIMAL |  | `NULL` |   |
| `tpm_level` | ENUM | Not null |   |   |
| `tpm_level_bysex` | ENUM |  | `NULL` |   |
| `tpm_f` | DECIMAL |  | `NULL` |   |
| `tpm_m` | DECIMAL |  | `NULL` |   |
| `log2foldchange` | DECIMAL |  | `NULL` |   |
| `tau` | DECIMAL |  | `NULL` |   |
| `tau_bysex` | DECIMAL |  | `NULL` |   |
| `uberon_id` | VARCHAR(20) |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| expression_idx1 | `protein_id` | INDEX |   |


## Table: `gwas`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `disease_trait` | VARCHAR(255) | Not null |   |   |
| `snps` | TEXT |  | `NULL` |   |
| `pmid` | INT |  | `NULL` |   |
| `study` | TEXT |  | `NULL` |   |
| `context` | TEXT |  | `NULL` |   |
| `intergenic` | TINYINT |  | `NULL` |   |
| `p_value` | DOUBLE |  | `NULL` |   |
| `or_beta` | FLOAT |  | `NULL` |   |
| `cnv` | CHAR(1) |  | `NULL` |   |
| `mapped_trait` | TEXT |  | `NULL` |   |
| `mapped_trait_uri` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| gwas_idx1 | `protein_id` | INDEX |   |


## Table: `hgram_cdf`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `type` | VARCHAR(255) | Not null |   |  **foreign key** to column `name` on table `gene_attribute_type`. |
| `attr_count` | INT | Not null |   |   |
| `attr_cdf` | DECIMAL | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| hgram_cdf_idx1 | `protein_id` | INDEX |   |
| hgram_cdf_idx2 | `type` | INDEX |   |


## Table: `homologene`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT |  | `NULL` |  **foreign key** to column `id` on table `protein`. |
| `nhprotein_id` | INT |  | `NULL` |  **foreign key** to column `id` on table `nhprotein`. |
| `groupid` | INT | Not null |   |   |
| `taxid` | INT | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| homologene_idx1 | `protein_id` | INDEX |   |
| homologene_idx2 | `nhprotein_id` | INDEX |   |


## Table: `idg_evol`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `tcrd_ver` | TINYINT | Not null |   |   |
| `tcrd_dbid` | INT | Not null |   |   |
| `name` | VARCHAR(255) | Not null |   |   |
| `description` | TEXT | Not null |   |   |
| `uniprot` | VARCHAR(20) | Not null |   |   |
| `sym` | VARCHAR(20) |  | `NULL` |   |
| `geneid` | INT |  | `NULL` |   |
| `tdl` | VARCHAR(6) | Not null |   |   |
| `fam` | VARCHAR(20) |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| idg_evol_idx1 | `uniprot` | INDEX |   |
| idg_evol_idx2 | `sym` | INDEX |   |
| idg_evol_idx3 | `geneid` | INDEX |   |
| idg_evol_idx4 | `name` | INDEX |   |


## Table: `info_type`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `name` | VARCHAR(255) | PRIMARY, Not null, Unique |   |   |
| `data_type` | VARCHAR(7) | Not null, Unique |   |  **foreign key** to column `name` on table `data_type`. |
| `unit` | VARCHAR(255) |  | `NULL` |   |
| `description` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `name` | PRIMARY |   |
| info_type_idx1 | `name`, `data_type` | UNIQUE |   |
| expression_type_idx1 | `name`, `data_type` | UNIQUE |   |
| fk_info_type__data_type | `data_type` | INDEX |   |


## Table: `kegg_distance`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `pid1` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `pid2` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `distance` | INT | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| kegg_distance_idx1 | `pid1` | INDEX |   |
| kegg_distance_idx2 | `pid2` | INDEX |   |


## Table: `kegg_nearest_tclin`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `tclin_id` | INT | Not null |   |  **foreign key** to column `id` on table `target`. |
| `direction` | ENUM | Not null |   |   |
| `distance` | INT | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| kegg_nearest_tclin_idx1 | `protein_id` | INDEX |   |
| kegg_nearest_tclin_idx2 | `tclin_id` | INDEX |   |


## Table: `lincs`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `cellid` | VARCHAR(10) | Not null |   |   |
| `zscore` | DECIMAL | Not null |   |   |
| `pert_dcid` | INT | Not null |   |   |
| `pert_smiles` | TEXT | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| lincs_idx1 | `protein_id` | INDEX |   |


## Table: `locsig`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `location` | VARCHAR(255) | Not null |   |   |
| `signal` | VARCHAR(255) | Not null |   |   |
| `pmids` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| compartment_idx1 | `protein_id` | INDEX |   |


## Table: `mlp_assay_info`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `assay_name` | TEXT | Not null |   |   |
| `method` | VARCHAR(255) | Not null |   |   |
| `active_sids` | INT |  | `NULL` |   |
| `inactive_sids` | INT |  | `NULL` |   |
| `iconclusive_sids` | INT |  | `NULL` |   |
| `total_sids` | INT |  | `NULL` |   |
| `aid` | INT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| mlp_assay_info_idx1 | `protein_id` | INDEX |   |


## Table: `mondo`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `mondoid` | VARCHAR(20) | PRIMARY, Not null |   |   |
| `name` | TEXT | Not null |   |   |
| `def` | TEXT |  | `NULL` |   |
| `comment` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `mondoid` | PRIMARY |   |


## Table: `mpo`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `mpid` | CHAR(10) | PRIMARY, Not null |   |   |
| `parent_id` | VARCHAR(10) |  | `NULL` |   |
| `name` | TEXT | Not null |   |   |
| `def` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `mpid` | PRIMARY |   |


## Table: `nhprotein`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `uniprot` | VARCHAR(20) | Not null, Unique |   |   |
| `name` | VARCHAR(255) | Not null |   |   |
| `description` | TEXT |  | `NULL` |   |
| `sym` | VARCHAR(30) |  | `NULL` |   |
| `species` | VARCHAR(40) | Not null |   |   |
| `taxid` | INT | Not null |   |   |
| `geneid` | INT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| nhprotein_idx1 | `uniprot` | UNIQUE |   |


## Table: `omim`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `mim` | INT | PRIMARY, Not null |   |   |
| `title` | VARCHAR(255) | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `mim` | PRIMARY |   |


## Table: `omim_ps`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `omim_ps_id` | CHAR(8) | Not null |   |   |
| `mim` | INT |  | `NULL` |  **foreign key** to column `mim` on table `omim`. |
| `title` | VARCHAR(255) | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| fk_omim_ps__omim | `mim` | INDEX |   |


## Table: `ortholog`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `taxid` | INT | Not null |   |   |
| `species` | VARCHAR(255) | Not null |   |   |
| `db_id` | VARCHAR(255) |  | `NULL` |   |
| `geneid` | INT |  | `NULL` |   |
| `symbol` | VARCHAR(255) | Not null |   |   |
| `name` | VARCHAR(255) | Not null |   |   |
| `mod_url` | TEXT |  | `NULL` |   |
| `sources` | VARCHAR(255) | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| ortholog_idx1 | `protein_id` | INDEX |   |


## Table: `ortholog_disease`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `did` | VARCHAR(255) | Not null |   |   |
| `name` | VARCHAR(255) | Not null |   |   |
| `ortholog_id` | INT | Not null |   |  **foreign key** to column `id` on table `ortholog`. |
| `score` | VARCHAR(255) | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| ortholog_disease_idx1 | `protein_id` | INDEX |   |
| ortholog_disease_idx2 | `ortholog_id` | INDEX |   |


## Table: `p2pc`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `panther_class_id` | INT | Not null |   |  **foreign key** to column `id` on table `panther_class`. |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| p2pc_idx1 | `panther_class_id` | INDEX |   |
| p2pc_idx2 | `protein_id` | INDEX |   |


## Table: `panther_class`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `pcid` | CHAR(7) | Not null, Unique |   |   |
| `parent_pcids` | VARCHAR(255) |  | `NULL` |   |
| `name` | TEXT | Not null |   |   |
| `description` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| panther_class_idx1 | `pcid` | UNIQUE |   |


## Table: `patent_count`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `year` | INT | Not null |   |   |
| `count` | INT | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| patent_count_idx1 | `protein_id` | INDEX |   |


## Table: `pathway`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `target_id` | INT |  | `NULL` |  **foreign key** to column `id` on table `target`. |
| `protein_id` | INT |  | `NULL` |  **foreign key** to column `id` on table `protein`. |
| `pwtype` | VARCHAR(255) | Not null |   |  **foreign key** to column `name` on table `pathway_type`. |
| `id_in_source` | VARCHAR(255) |  | `NULL` |   |
| `name` | TEXT | Not null |   |   |
| `description` | TEXT |  | `NULL` |   |
| `url` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| pathway_idx1 | `target_id` | INDEX |   |
| pathway_idx2 | `protein_id` | INDEX |   |
| pathway_idx3 | `pwtype` | INDEX |   |


## Table: `pathway_type`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `name` | VARCHAR(255) | PRIMARY, Not null |   |   |
| `url` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `name` | PRIMARY |   |


## Table: `phenotype`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `ptype` | VARCHAR(255) | Not null |   |  **foreign key** to column `name` on table `phenotype_type`. |
| `protein_id` | INT |  | `NULL` |  **foreign key** to column `id` on table `protein`. |
| `nhprotein_id` | INT |  | `NULL` |  **foreign key** to column `id` on table `nhprotein`. |
| `trait` | TEXT |  | `NULL` |   |
| `top_level_term_id` | VARCHAR(255) |  | `NULL` |   |
| `top_level_term_name` | VARCHAR(255) |  | `NULL` |   |
| `term_id` | VARCHAR(255) |  | `NULL` |   |
| `term_name` | VARCHAR(255) |  | `NULL` |   |
| `term_description` | TEXT |  | `NULL` |   |
| `p_value` | DOUBLE |  | `NULL` |   |
| `percentage_change` | VARCHAR(255) |  | `NULL` |   |
| `effect_size` | VARCHAR(255) |  | `NULL` |   |
| `procedure_name` | VARCHAR(255) |  | `NULL` |   |
| `parameter_name` | VARCHAR(255) |  | `NULL` |   |
| `gp_assoc` | TINYINT |  | `NULL` |   |
| `statistical_method` | TEXT |  | `NULL` |   |
| `sex` | VARCHAR(8) |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| phenotype_idx1 | `ptype` | INDEX |   |
| phenotype_idx2 | `protein_id` | INDEX |   |
| phenotype_idx3 | `nhprotein_id` | INDEX |   |


## Table: `phenotype_type`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `name` | VARCHAR(255) | PRIMARY, Not null, Unique |   |   |
| `ontology` | VARCHAR(255) | Unique | `NULL` |   |
| `description` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `name` | PRIMARY |   |
| phenotype_type_idx1 | `name`, `ontology` | UNIQUE |   |


## Table: `pmscore`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `year` | INT | Not null |   |   |
| `score` | DECIMAL | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| pmscore_idx1 | `protein_id` | INDEX |   |


## Table: `ppi`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `ppitype` | VARCHAR(255) | Not null |   |   |
| `protein1_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `protein1_str` | VARCHAR(255) |  | `NULL` |   |
| `protein2_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `protein2_str` | VARCHAR(255) |  | `NULL` |   |
| `p_int` | DECIMAL |  | `NULL` |   |
| `p_ni` | DECIMAL |  | `NULL` |   |
| `p_wrong` | DECIMAL |  | `NULL` |   |
| `evidence` | VARCHAR(255) |  | `NULL` |   |
| `interaction_type` | VARCHAR(100) |  | `NULL` |   |
| `score` | INT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| ppi_idx1 | `protein1_id` | INDEX |   |
| ppi_idx2 | `protein2_id` | INDEX |   |
| ppi_idx3 | `ppitype` | INDEX |   |


## Table: `ppi_type`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `name` | VARCHAR(255) | PRIMARY, Not null |   |   |
| `description` | TEXT |  | `NULL` |   |
| `url` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `name` | PRIMARY |   |


## Table: `protein`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `name` | VARCHAR(255) | Not null, Unique |   |   |
| `description` | TEXT | Not null |   |   |
| `uniprot` | VARCHAR(20) | Not null, Unique |   |   |
| `up_version` | INT |  | `NULL` |   |
| `geneid` | INT |  | `NULL` |   |
| `sym` | VARCHAR(20) |  | `NULL` |   |
| `family` | VARCHAR(255) |  | `NULL` |   |
| `chr` | VARCHAR(255) |  | `NULL` |   |
| `seq` | TEXT |  | `NULL` |   |
| `dtoid` | VARCHAR(13) |  | `NULL` |   |
| `stringid` | VARCHAR(15) |  | `NULL` |   |
| `dtoclass` | VARCHAR(255) |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| protein_idx1 | `uniprot` | UNIQUE |   |
| protein_idx2 | `name` | UNIQUE |   |


## Table: `protein2pubmed`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `pubmed_id` | INT | Not null |   |  **foreign key** to column `id` on table `pubmed`. |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| protein2pubmed_idx1 | `protein_id` | INDEX |   |
| protein2pubmed_idx2 | `pubmed_id` | INDEX |   |


## Table: `provenance`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `dataset_id` | INT | Not null |   |  **foreign key** to column `id` on table `dataset`. |
| `table_name` | VARCHAR(255) | Not null |   |   |
| `column_name` | VARCHAR(255) |  | `NULL` |   |
| `where_clause` | TEXT |  | `NULL` |   |
| `comment` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| provenance_idx1 | `dataset_id` | INDEX |   |


## Table: `ptscore`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `year` | INT | Not null |   |   |
| `score` | DECIMAL | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| ptscore_idx1 | `protein_id` | INDEX |   |


## Table: `pubmed`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Not null |   |   |
| `title` | TEXT | Not null |   |   |
| `journal` | TEXT |  | `NULL` |   |
| `date` | VARCHAR(10) |  | `NULL` |   |
| `authors` | TEXT |  | `NULL` |   |
| `abstract` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |


## Table: `rat_qtl`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `nhprotein_id` | INT | Not null |   |  **foreign key** to column `id` on table `nhprotein`. |
| `rgdid` | INT | Not null |   |   |
| `qtl_rgdid` | INT | Not null |   |   |
| `qtl_symbol` | VARCHAR(10) | Not null |   |   |
| `qtl_name` | VARCHAR(255) | Not null |   |   |
| `trait_name` | VARCHAR(255) |  | `NULL` |   |
| `measurement_type` | VARCHAR(255) |  | `NULL` |   |
| `associated_disease` | VARCHAR(255) |  | `NULL` |   |
| `phenotype` | VARCHAR(255) |  | `NULL` |   |
| `p_value` | DECIMAL |  | `NULL` |   |
| `lod` | FLOAT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| rat_qtl_idx1 | `nhprotein_id` | INDEX |   |


## Table: `rat_term`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `rgdid` | INT | Not null, Unique |   |   |
| `term_id` | VARCHAR(20) | Not null, Unique |   |   |
| `obj_symbol` | VARCHAR(20) |  | `NULL` |   |
| `term_name` | VARCHAR(255) |  | `NULL` |   |
| `qualifier` | VARCHAR(20) |  | `NULL` |   |
| `evidence` | VARCHAR(5) |  | `NULL` |   |
| `ontology` | VARCHAR(40) |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| rat_term_idx1 | `rgdid`, `term_id` | UNIQUE |   |


## Table: `rdo`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `doid` | VARCHAR(12) | PRIMARY, Not null |   |   |
| `name` | TEXT | Not null |   |   |
| `def` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `doid` | PRIMARY |   |


## Table: `rdo_xref`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `doid` | VARCHAR(12) | PRIMARY, Not null |   |  **foreign key** to column `doid` on table `rdo`. |
| `db` | VARCHAR(24) | PRIMARY, Not null |   |   |
| `value` | VARCHAR(24) | PRIMARY, Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `doid`, `db`, `value` | PRIMARY |   |
| rdo_xref__idx2 | `db`, `value` | INDEX |   |


## Table: `t2tc`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `target_id` | INT | Not null |   |  **foreign key** to column `id` on table `target`. |
| `protein_id` | INT |  | `NULL` |  **foreign key** to column `id` on table `protein`. |
| `nucleic_acid_id` | INT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| t2tc_idx1 | `target_id` | INDEX |   |
| t2tc_idx2 | `protein_id` | INDEX |   |


## Table: `target`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `name` | VARCHAR(255) | Not null |   |   |
| `ttype` | VARCHAR(255) | Not null |   |   |
| `description` | TEXT |  | `NULL` |   |
| `comment` | TEXT |  | `NULL` |   |
| `tdl` | ENUM |  | `NULL` |   |
| `idg` | TINYINT | Not null | `'0'` |   |
| `fam` | ENUM |  | `NULL` |   |
| `famext` | VARCHAR(255) |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |


## Table: `tdl_info`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `itype` | VARCHAR(255) | Not null |   |  **foreign key** to column `name` on table `info_type`. |
| `target_id` | INT |  | `NULL` |  **foreign key** to column `id` on table `target`. |
| `protein_id` | INT |  | `NULL` |  **foreign key** to column `id` on table `protein`. |
| `nucleic_acid_id` | INT |  | `NULL` |   |
| `string_value` | TEXT |  | `NULL` |   |
| `number_value` | DECIMAL |  | `NULL` |   |
| `integer_value` | INT |  | `NULL` |   |
| `date_value` | DATE |  | `NULL` |   |
| `boolean_value` | TINYINT |  | `NULL` |   |
| `curration_level` | VARCHAR(50) |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| tdl_info_idx1 | `itype` | INDEX |   |
| tdl_info_idx2 | `target_id` | INDEX |   |
| tdl_info_idx3 | `protein_id` | INDEX |   |


## Table: `techdev_contact`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Not null |   |   |
| `contact_name` | VARCHAR(255) | Not null |   |   |
| `contact_email` | VARCHAR(255) | Not null |   |   |
| `date` | DATE |  | `NULL` |   |
| `grant_number` | VARCHAR(255) |  | `NULL` |   |
| `pi` | VARCHAR(255) | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |


## Table: `techdev_info`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `contact_id` | INT |  | `NULL` |  **foreign key** to column `id` on table `techdev_contact`. |
| `protein_id` | INT |  | `NULL` |  **foreign key** to column `id` on table `protein`. |
| `comment` | TEXT | Not null |   |   |
| `publication_pcmid` | VARCHAR(255) |  | `NULL` |   |
| `publication_pmid` | INT |  | `NULL` |   |
| `resource_url` | TEXT |  | `NULL` |   |
| `data_url` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| techdev_info_idx1 | `contact_id` | INDEX |   |
| techdev_info_idx2 | `protein_id` | INDEX |   |


## Table: `tiga`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `ensg` | VARCHAR(15) | Not null |   |   |
| `efoid` | VARCHAR(15) | Not null |   |   |
| `trait` | VARCHAR(255) | Not null |   |   |
| `n_study` | INT |  | `NULL` |   |
| `n_snp` | INT |  | `NULL` |   |
| `n_snpw` | DECIMAL |  | `NULL` |   |
| `geneNtrait` | INT |  | `NULL` |   |
| `geneNstudy` | INT |  | `NULL` |   |
| `traitNgene` | INT |  | `NULL` |   |
| `traitNstudy` | INT |  | `NULL` |   |
| `pvalue_mlog_median` | DECIMAL |  | `NULL` |   |
| `pvalue_mlog_max` | DECIMAL |  | `NULL` |   |
| `or_median` | DECIMAL |  | `NULL` |   |
| `n_beta` | INT |  | `NULL` |   |
| `study_N_mean` | INT |  | `NULL` |   |
| `rcras` | DECIMAL |  | `NULL` |   |
| `meanRank` | DECIMAL |  | `NULL` |   |
| `meanRankScore` | DECIMAL |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| tiga_idx1 | `protein_id` | INDEX |   |


## Table: `tiga_provenance`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `ensg` | VARCHAR(15) | Not null |   |   |
| `efoid` | VARCHAR(15) | Not null |   |   |
| `study_acc` | VARCHAR(20) | Not null |   |   |
| `pubmedid` | INT | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |


## Table: `tinx_articlerank`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `doid` | VARCHAR(20) | Not null |   |   |
| `protein_id` | INT | Not null |   |   |
| `pmid` | INT | Not null |   |   |
| `rank` | INT | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| tinx_articlerank_idx1 | `doid`, `protein_id` | INDEX |   |
| tinx_articlerank_idx2 | `pmid` | INDEX |   |


## Table: `tinx_disease`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `doid` | VARCHAR(20) | PRIMARY, Not null |   |   |
| `name` | TEXT | Not null |   |   |
| `summary` | TEXT |  | `NULL` |   |
| `score` | DECIMAL |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `doid` | PRIMARY |   |


## Table: `tinx_importance`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `doid` | VARCHAR(20) | PRIMARY, Not null |   |  **foreign key** to column `doid` on table `tinx_disease`. |
| `protein_id` | INT | PRIMARY, Not null |   |  **foreign key** to column `id` on table `protein`. |
| `score` | DECIMAL | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `doid`, `protein_id` | PRIMARY |   |
| tinx_importance_idx1 | `protein_id` | INDEX |   |
| tinx_importance_idx2 | `doid` | INDEX |   |


## Table: `tinx_novelty`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `protein`. |
| `score` | DECIMAL | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| tinx_novelty_idx1 | `protein_id` | INDEX |   |


## Table: `uberon`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `uid` | VARCHAR(20) | PRIMARY, Not null |   |   |
| `name` | TEXT | Not null |   |   |
| `def` | TEXT |  | `NULL` |   |
| `comment` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `uid` | PRIMARY |   |


## Table: `uberon_parent`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `uid` | VARCHAR(20) | Not null |   |  **foreign key** to column `uid` on table `uberon`. |
| `parent_id` | VARCHAR(20) | Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| fk_uberon_parent__uberon | `uid` | INDEX |   |


## Table: `uberon_xref`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `uid` | VARCHAR(20) | PRIMARY, Not null |   |  **foreign key** to column `uid` on table `uberon`. |
| `db` | VARCHAR(24) | PRIMARY, Not null |   |   |
| `value` | VARCHAR(255) | PRIMARY, Not null |   |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `uid`, `db`, `value` | PRIMARY |   |


## Table: `viral_ppi`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `viral_protein_id` | INT | Not null |   |  **foreign key** to column `id` on table `viral_protein`. |
| `protein_id` | INT |  | `NULL` |  **foreign key** to column `id` on table `protein`. |
| `dataSource` | VARCHAR(20) |  | `NULL` |   |
| `finalLR` | DECIMAL | Not null |   |   |
| `pdbIDs` | VARCHAR(128) |  | `NULL` |   |
| `highConfidence` | TINYINT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| viral_protein_id_idx | `viral_protein_id` | INDEX |   |
| protein_id_idx | `protein_id` | INDEX |   |
| high_conf_idx | `highConfidence` | INDEX |   |


## Table: `viral_protein`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Not null |   |   |
| `name` | VARCHAR(128) |  | `NULL` |   |
| `ncbi` | VARCHAR(128) |  | `NULL` |   |
| `virus_id` | VARCHAR(16) |  | `NULL` |  **foreign key** to column `virusTaxid` on table `virus`. |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| virus_id_idx | `virus_id` | INDEX |   |


## Table: `virus`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `virusTaxid` | VARCHAR(16) | PRIMARY, Not null |   |   |
| `nucleic1` | VARCHAR(128) |  | `NULL` |   |
| `nucleic2` | VARCHAR(128) |  | `NULL` |   |
| `order` | VARCHAR(128) |  | `NULL` |   |
| `family` | VARCHAR(128) |  | `NULL` |   |
| `subfamily` | VARCHAR(128) |  | `NULL` |   |
| `genus` | VARCHAR(128) |  | `NULL` |   |
| `species` | VARCHAR(128) |  | `NULL` |   |
| `name` | VARCHAR(128) |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `virusTaxid` | PRIMARY |   |


## Table: `xref`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `id` | INT | PRIMARY, Auto increments, Not null |   |   |
| `xtype` | VARCHAR(255) | Not null, Unique |   |  **foreign key** to column `name` on table `xref_type`. |
| `target_id` | INT | Unique | `NULL` |  **foreign key** to column `id` on table `target`. |
| `protein_id` | INT | Unique | `NULL` |  **foreign key** to column `id` on table `protein`. |
| `nucleic_acid_id` | INT |  | `NULL` |   |
| `value` | VARCHAR(255) | Not null, Unique |   |   |
| `xtra` | VARCHAR(255) |  | `NULL` |   |
| `dataset_id` | INT | Not null |   |  **foreign key** to column `id` on table `dataset`. |
| `nhprotein_id` | INT |  | `NULL` |  **foreign key** to column `id` on table `nhprotein`. |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `id` | PRIMARY |   |
| xref_idx3 | `xtype`, `target_id`, `value` | UNIQUE |   |
| xref_idx5 | `xtype`, `protein_id`, `value` | UNIQUE |   |
| xref_idx1 | `xtype` | INDEX |   |
| xref_idx2 | `target_id` | INDEX |   |
| xref_idx4 | `protein_id` | INDEX |   |
| xref_idx6 | `dataset_id` | INDEX |   |
| fk_xref_nhprotein | `nhprotein_id` | INDEX |   |


## Table: `xref_type`

### Description: 



### Columns: 

| Column | Data type | Attributes | Default | Description |
| --- | --- | --- | --- | ---  |
| `name` | VARCHAR(255) | PRIMARY, Not null |   |   |
| `description` | TEXT |  | `NULL` |   |
| `url` | TEXT |  | `NULL` |   |
| `eg_q_url` | TEXT |  | `NULL` |   |


### Indices: 

| Name | Columns | Type | Description |
| --- | --- | --- | --- |
| PRIMARY | `name` | PRIMARY |   |


Generated by MySQL Workbench Model Documentation v1.0.0 - Copyright (c) 2015 Hieu Le
