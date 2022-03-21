# Analyses of plant fitness

This folder contains data and code to recreate all the results relating to differences in plant fitness.

Data files:

- `field_expt_fitness_data.csv`: Plant fitness data from the field experiment previously published by [Thiergart *et al.* (2020)](https://www.nature.com/articles/s41559-019-1063-3/), showing:
  + `Site`: Experimental site
  + `Tray`: Tray ID
  + `Block`: Block ID. There were 6 blocks of 42 plants per tray.
  + `Pos`: Position within each block
  + `Soil`: Soil matrix
  + `Genotype`: Plant genotype
  + `fruits_per_seedling`: Plant fitness, measured as number of fruits produced.
- `gnotobiotic_expt_fitness_data.csv`: Block-mean fitness data from the growth-chamber experiment, showing:
  + `trt`: Numerical code indicating overall soil treatment
  + `Climate`: Growth-chamber climate program.
  + `Soil`: source of the soil matrix
  + `Sterile`: whether soil was autoclaved or not
  + `Tea`: Mircobial inoculum
  + `geno`: Plant genotype
  + `tub`: Block ID
  + `fruits_per_seedling`: Plant fitness; number of fruits produced divided by the number of seedlings planted (that survived transplant shock)
  + `plants_per_block`: Number of plants of this genotype in the block surviving transplant shock.

ANOVA models and figures are created with the Rmarkdown file `plant_fitness.Rmd`.
Note that for publication figures were further edited in Adobe Illustrator by Stéphane Hacquard.

Full details of the R session is given in `session_info.txt`.
