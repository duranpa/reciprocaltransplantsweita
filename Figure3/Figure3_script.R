BACTERIA
###Figure3b 
#load data
design<- read.table("design_filt2.txt", header=TRUE, sep="\t", check.names=FALSE)
#for bacteria
asv_table<- read.table("asv_table_b5.txt", header=TRUE, sep="\t", check.names=FALSE)
#for fungi
asv_table<- read.table("asv_table_its1.txt", header=TRUE, sep="\t", check.names=FALSE)

# normalize otu tables
library('ggplot2')
library('GUniFrac')
library('vegan')

asv_raref <- Rarefy(t(asv_table), 1000)
asv_raref <- t(asv_raref$otu.tab.rff)

#select treatments of interest
d <- design[design$Condition %in% c("Repopulated", "Repopulated_changed_climate", "Changed_soil", "Changed_soil_climate"), ]
d<- d[d$Fraction %in% c("Soil"), ]
d<- d[d$Planted %in% c("Planted"), ]

idx <- colnames(asv_raref) %in% d$SampleID

#calculate Bray-Curtis dissimilarities
bray_curtis <- vegdist(t(asv_raref[, idx]), method="bray")
bray_curtis<- as.matrix(bray_curtis)

#remove samples in design file which are not in the BrayCurtis (removed after rarefaction)
idx<- d$SampleID %in% colnames(bray_curtis)
d<- d[idx,]

#organize factors to fit color-code
d$Condition<- factor(d$Condition, levels=c("Repopulated", "Repopulated_changed_climate", "Changed_soil", "Changed_soil_climate"))

colors <- data.frame(group=c("Repopulated", "Repopulated_changed_climate", "Changed_soil", "Changed_soil_climate"),
                     color=c("#808080", "#FFC966", "#6666FF","#631919"))			
shapes <- data.frame(group=c("Italian", "Swedish"),
                     shape=c(16, 17))	

#calculate PCoA coordinates
k <- 2
pcoa <- cmdscale(bray_curtis, k=k, eig=T)
points <- pcoa$points
eig <- pcoa$eig
points <- as.data.frame(points)
colnames(points) <- c("x", "y")

#merge design information with sample coordinates
points <- cbind(points, design[match(rownames(points), design$SampleID), ])
points$Microbe<- factor(points$Microbe, levels=shapes$group)
points$Condition <- factor(points$Condition, levels=colors$group)

##plot
source("plotting_functions.R")
p <- ggplot(points, aes(x=x, y=y, color=Condition, shape=Microbe))+
  geom_point(alpha=1, size=6) +
  scale_colour_manual(values=as.character(colors$color)) +
  scale_shape_manual(values=shapes$shape) +
  labs(x=paste("PCoA 1 (", format(100 * eig[1] / sum(eig), digits=4), "%)", sep=""),
       y=paste("PCoA 2 (", format(100 * eig[2] / sum(eig), digits=4), "%)", sep="")) + 
  main_theme +
  theme(legend.position="top")


###(input for)Figure3c and Table2
#calculate variance explained by different factors in Figure3 b
adonis(bray_curtis ~Chamber*Soil*Genotype*Wash, data = d, permutations = 999,      method = "bray", strata = NULL)

#plot variances
##substracted output information from adonis and created a dataframe with variance and design information

variance<- read.table("variance.txt", header=TRUE, sep="\t")
var<- variance[variance$Experiment %in% c("Chamber_transplant"), ]
var$Factor<- factor(var$Factor, levels=c("Chamber", "Soil","Genotype","Wash", "Chamber_Soil","Chamber_Wash","Soil_Wash","Chamber_Soil_Wash", "un"))

p <- ggplot(var, aes(x=Factor, y=Variance)) +
  geom_bar(stat="identity")
p+facet_wrap(vars(Microbe), scales="free")+theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

## (input for) Figure 3d
##same subsetted asv_table and design as for Figure 3b and c

library('reshape2')
library('tidyverse')
library('magrittr')
library('DESeq2')
library('sva')

#subset taxonomy file to contain only the ASVs in asv_table
taxonomy<- read.table("taxonomy_b5_mod.txt", header=TRUE, sep="\t")
idx <- taxonomy$Feature.ID %in% rownames(asv_raref)
taxonomy<- taxonomy[idx,]

#aggregate (sum asv reads) asv_table at the family level
level <- which(colnames(taxonomy)=="Family_mod")
asv_raref_fam<- aggregate(asv_raref, by=list(taxonomy[, level]), FUN=sum)

#saved files to read them again as tsv
write.table(asv_raref_fam, "asv_raref_fam_forenrich_b5.txt", sep="\t")
write.table(d, "d_forenrich_b5.txt", sep="\t")

#load files again
asvRaw <- read_tsv('asv_raref_fam_forenrich_b5.txt')
expDesign <- read_tsv('d_forenrich_b5.txt')

countData <- asvRaw %>%
  mutate_all(~ifelse(. == 0, 1, .)) %>%
  column_to_rownames('Family') %>% ## add small value
  select(expDesign$SampleID) %>%
  set_colnames(str_replace_all(colnames(.), '\\.', '_')) %>%
  set_rownames(rownames(asvRaw))

designData <- expDesign %>%
  mutate(treatment = Condition_microbe %>% str_replace('-', '_')) %>%
  column_to_rownames('SampleID') %>%
  set_rownames(str_replace_all(rownames(.), '\\.', '_'))

#check
colnames(countData) == rownames(designData)

asvres <- DESeqDataSetFromMatrix(countData,
                                 designData,
                                 ~Condition_microbe)

design(asvres) <- ~ Condition_microbe
asvres <- DESeq(asvres)

## select treatments to be compared
resultsNames(asvres)

cond <- list(c('Repopulated_Swedish', 'Repopulated_changed_climate_Swedish'),
             c('Repopulated_Swedish', 'Changed_soil_climate_Swedish'),
             c('Repopulated_Italian', 'Repopulated_changed_climate_Italian'),
             c('Repopulated_Italian', 'Changed_soil_climate_Italian'),
             c('Repopulated_Swedish', 'Changed_soil_Swedish'),
             c('Repopulated_Italian', 'Changed_soil_Italian'))

resRaw <- lapply(cond,
                 function(x) {
                   asvres %>%
                     results(contrast = c('Condition_microbe', x)) %T>%
                     summary %>%
                     as_tibble %>%
                     select(pvalue, padj, log2FoldChange) %>%
                     rename_all(.funs = list(~paste0(paste(x, collapse = '_vs_'), '_', .)))
                 }) %>%
  bind_cols

res <- cbind.data.frame(as.matrix(mcols(asvres)[, 1:10]), counts(asvres, normalize = TRUE), stringsAsFactors = FALSE) %>%
  rownames_to_column(., var = 'ID') %>%
  as_tibble %>%
  bind_cols(resRaw)

write.table(resRaw, "enriched_raw_repop_b5_family.txt", sep="\t")
write.table(res, "enriched_res_repop_b5_family.txt", sep="\t")

##manually subsetted those families which were significantly different (see yellow highlighted families in Supplementary Table 2) and separated them by microbial origin
#Figure 3d
##venn diagramm
library('ggvenn')

ita<- read.table("enriched_families_italian.txt", header=TRUE, sep="\t")
swe<- read.table("enriched_families_swedish.txt", header=TRUE, sep="\t")
ggVennDiagram(ita, label_alpha = 0)
ggVennDiagram(swe, label_alpha = 0)



