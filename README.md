# reciprocaltransplantsweita

Scripts and raw data for Duran, Ellis et al. 2021, investigating the
interactions between soil microbes, abiotic soil matrix, climate, and plant 
(*Arabidopsis thaliana*) genotype.

## Analyses

### Growth chamber schedules

Files and scripts to recreate the growth chamber programs mimicking the climates
at the experimental sites in Sweden and Italy in the winter of 2005-6.

### Microbiota data analysis
Files and scripts to recreate figures shown in the manuscript. Each script requires different input files:

#Figure 3:
design_filt2.txt
asv_table_b5.txt
asv_table_its1.txt
enriched_families_italian_b5.txt
enriched_families_italian_its1.txt
enriched_families_swedish_b5.txt
enriched_families_swedish_its.txt

#Supplementary Figure 1:
design_controls.txt
asv_table_b5.txt
asv_table_its1.txt

#Supplementary Figure 2:
design_complete.txt
asv_table_b5.txt
asv_table_its1.txt
long_asv_table_norm_enriched_b5.txt
long_asv_table_norm_enriched_its1.txt

#Supplementary Figure 4 c + e:
design_asfield.txt
asv_table_b5.txt
asv_table_its1.txt

#Supplementary Figure 4 d + f:
design_b5.txt
design_its1.txt
otu_table_check_b5.txt
otu_table_check_its1.txt

#Supplementary Figure 5:
design_filt2.txt
asv_table_b5.txt
asv_table_its1.txt

## Dependencies

### R
- chron


