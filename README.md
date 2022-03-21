# Climate drives rhizosphere microbiome variation and divergent selection between geographically distant Arabidopsis populations

Scripts and raw data for Duran, Ellis et al. 2021, investigating the
interactions between soil microbes, abiotic soil matrix, climate, and plant 
(*Arabidopsis thaliana*) genotype.

## Analyses

### Growth chamber schedules

Files and scripts to recreate the growth chamber programs mimicking the climates
at the experimental sites in Sweden and Italy in the winter of 2005-6.

### Randomisation

Scripts to create the randomisation plan to set up the experiment.

### Plant fitness

Scripts to analyse results relating to differences in plant fitness.

### Microbiota data analysis

Files and scripts to recreate figures shown in the manuscript. ASV tables and files that are shared across several figures are found in the main path reciprocaltransplantsweita/, otherwise each folder contains all the necessary files and scripts to reproduce the figures. All analysis are run within the same folder and no external files need to be called, with two exceptions (see below). 
To reproduce each folder's figure, download the required files to your working directory. Each design file will contain all technical and experimental information for each sample, to produce the manuscript's analysis and additional ones if required. Each folder also contains a readme file where we explain step by step the overall idea of what was done. Each script will produce one or multiple plots which we then stiched up together in Illustrator (v24.1.3) where we also modified figure legends and graphs' axis manually. 

To get these analyses to work, load the following scripts first:

- `cpcoa.R` for constrained principal components analysis
- `plotting_functions.R` for plotting aesthetics

## Dependencies

### R (minimum version 4.1)

For analysis of plant fitness:

- tidyverse
- lmerTest
- ggpubr
- cowplot
- gridGraphics
- rmarkdown

For microbial analyses:

- chron
- ggplot2
- GUnifrac
- vegan
- reshape2
- tidyverse
- magrittr
- DESeq2
- agricolae


