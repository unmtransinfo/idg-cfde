library(readr)
library(data.table)

# LOINC codes for chemical tests
loinc_chem <- read_delim("data/loinc_chem_names.tsv", "\t")
setDT(loinc_chem)
message(sprintf("LOINC codes: %d", loinc_chem[, uniqueN(loinc_num)]))

# NextMove LeadMine NER output using GeneAndProtein dictionary for columns "component" and "relatednames2".
gene_NER_component <- read_delim("data/loinc_chem_names_2_NM_CFDictGeneAndProtein_leadmine.tsv", "\t")
setDT(gene_NER_component)
message(sprintf("LOINC codes mapped via component text to NER genes: %d", gene_NER_component[, uniqueN(DocName)]))

gene_NER_relatednames <-  read_delim("data/loinc_chem_names_6_NM_CFDictGeneAndProtein_leadmine.tsv", "\t")
setDT(gene_NER_relatednames)
message(sprintf("LOINC codes mapped via relatednames2 text to NER genes: %d", gene_NER_relatednames[, uniqueN(DocName)]))

# Cerner HealthFacts 2019 counts of encounter_ids and patient_ids for all LOINC codes.
hf_loinc_counts <- read_delim("data/hf_lab_loinc_counts_OUT.tsv", "\t")
setDT(hf_loinc_counts)
message(sprintf("LOINC codes in HF encounters: %d", hf_loinc_counts[, uniqueN(loinc_code)]))

# 
gene_hr_loincs_component <- merge(gene_NER_component, hf_loinc_counts, by.x="DocName", by.y="loinc_code", all=F)
gene_hr_loincs_relatednames <- merge(gene_NER_relatednames, hf_loinc_counts, by.x="DocName", by.y="loinc_code", all=F)
gene_hr_loincs <- rbind(gene_hr_loincs_component, gene_hr_loincs_relatednames)
message(sprintf("LOINC codes for genes in HF encounters: %d", gene_hr_loincs[, uniqueN(DocName)]))
message(sprintf("LOINC gene names in HF encounters: %d", gene_hr_loincs[, uniqueN(EntityText)]))
#
gene_hr_loincs_out <- unique(gene_hr_loincs[, .(loinc_code=DocName, gene_name=EntityText, encounter_id_count, patient_id_count)])
gene_hr_loincs_out <- gene_hr_loincs_out[order(-encounter_id_count)]
# Top occurring LOINCs:
print(gene_hr_loincs_out[1:20])
#
write_delim(gene_hr_loincs_out, "data/biomarkers_loinc_hf_out.tsv", delim="\t")