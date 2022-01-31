# reciprocaltransplantsweita

Scripts and raw data for Duran, Ellis et al. 2021, investigating the
interactions between soil microbes, abiotic soil matrix, climate, and plant 
(*Arabidopsis thaliana*) genotype.

## Analyses

### Growth chamber schedules

Files and scripts to recreate the growth chamber programs mimicking the climates
at the experimental sites in Sweden and Italy in the winter of 2005-6.

### Microbiota data analysis
Files and scripts to recreate figures shown in the manuscript. ASV tables and files that are shared across several figures are found in the main path reciprocaltransplantsweita/, otherwise each folder contains all the necessary files and scripts to reproduce the figures. All analysis are run within the same folder and no external files need to be called, with two exceptions (see below).

## Dependencies

### R (minimum version 4.1)
- chron
- ggplot2
- GUnifrac
- vegan
- reshape2
- tidyverse
- magrittr
- DESeq2

for microbiota analysis, load the following scripts first:
#for constrained principal components analysis
cpcoa.R
#for plotting aesthetics
plotting_functions.R


