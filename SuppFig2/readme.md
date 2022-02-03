In Figure 3:
1) We first calculate the dissimilarity between microbial communities in control samples (without treatment and at the end of the experiment)(Bray Curtis dissimilarities) and we calculate the coordinates for each sample to plot them (seen in SuppFig2b)
3) We assess the bacterial and fungal ASVs that are significantly different between repopulated samples compared to the untreated soils. For that, we use ASVs table for the differential abundance analysis, using the DESeq package
4) From the output, we select those families that are significantly different at a p<0.05, and we generate new tables (enriched_families_italian_b5.txt etc) to plot the venn diagrams showing the overlap of families changed in each condition (Figure 3d)
