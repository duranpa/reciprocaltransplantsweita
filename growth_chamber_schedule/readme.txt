Tom Ellis 24th March 2016.

This folder contains documents and datasets pertaining to the growth chamber schedules intended to mimic the climate experienced at the Rödåsen and Castelnuovo sites in the winter 2005/2006.
Paths to files are relative to the project folder, so they will only run if your working directory is there (for example, if you are using an Rstudio project, which is a good idea).

Files included:

160321 2005/6 schedule.PDF
Document explaining how the schedule was created

160321 2005/6 schedule.Rmd
R markdown file used to compile the PDF, including the R code to do create the schedule. This can most easily be viewed in R studio.

belm_2005-6_schedule.csv
roda_2005-6_schedule.csv
The schedule files the .Rmd file produces

dittmar_belm.csv
dittmar_roda.csv
The schedule used in the Dittmar et al. 2014 paper, taken from Dryad doi:10.5061/dryad.m663t

belmonte_dataloggers.csv
rodasen_dataloggers.csv
Data from the temperature loggers ay the two sites between 2003 and 2015

photoperiod_rome_2005-6.csv
photoperiod_sundsvall_2005-6.csv
Data on sunrise and sunset for Sundsvall and Rome in 2005/6. The extra columns are two hours before and after sunrise and sunset. Daylength is the photoperiod, and nhours the photoperiod in absolute number of hours.

roda_meanPAR.Rdata
belm_meanPAR.Rdata
R objects describing daily means in PAR between sunrise and sunset from 2005/09/15 to 2006/6/23  in Sweden and 2005/11/30 to 2006/04/30 in Italy. I have not included the raw data from the field loggers because (1) these files are enormous, and (2) the time/date data are very slow to deal with in R.

evolution.csl
arabidopsis.bib
Auxilliary files to compile the reference and bibliography in the .Rmd file
