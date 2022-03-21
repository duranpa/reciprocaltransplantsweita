In Supplementary Figure 2:
1) We first calculate the dissimilarity between microbial communities in control samples (without treatment and at the end of the experiment)(Bray Curtis dissimilarities) and we calculate the coordinates for each sample to plot them (seen in SuppFig2b)
3) We assess the bacterial and fungal ASVs that are significantly different between repopulated samples compared to the untreated soils. For that, we use ASVs table for the differential abundance analysis, using the DESeq package.
4) We also calculate the relative abundance of each ASV in a given sample, using the full ASV dataset.
5) From the output of the differential abundance analysis, we select those ASVs that are significantly different at a p<0.05, and subset the relative abundances ASV table. We then "melt" this table and add the information about which treatment and microbial group each sample belongs to, and which phylum each ASV is assigned to (long_asv_table_norm_enriched_b5/its1.txt)
6) We then calculate the average relative abundance for each ASV and the standard error, so that we plot these data as bar plots with whiskers (seen in SuppFig2c)
