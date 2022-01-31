#load data
design<- read.table("design_complete.txt", header=TRUE, sep="\t", check.names=FALSE)
#bacteria
asv_table<- read.table("asv_table_b5.txt", header=TRUE, sep="\t", check.names=FALSE)
#fungi
asv_table<- read.table("asv_table_its1.txt", header=TRUE, sep="\t", check.names=FALSE)

# normalize otu tables
library(ggplot2)
library("GUniFrac")

asv_raref <- Rarefy(t(asv_table), 1000)
asv_raref <- t(asv_raref$otu.tab.rff)

#select treatments to analyze
d <- design[design$Condition %in% c("Control", "Repopulated", "Autoclaved"), ]
d<- d[d$Fraction %in% c("Soil"), ]
d<- d[d$Planted %in% c("Planted"), ]

idx <- colnames(asv_raref) %in% d$SampleID

#calculate Bray Curtis distances
bray_curtis <- vegdist(t(asv_raref[, idx]), method="bray")
bray_curtis<- as.matrix(bray_curtis)

colors <- data.frame(group=c("Autoclaved", "Control", "Repopulated"),
                     color=c("#f2f2f2", "#000000","#808080"))		
shapes <- data.frame(group=c("Italian","Swedish"),
                     shape=c(16, 17))	

#calculate sample coordinates based on Bray Curtis distances
k <- 2
pcoa <- cmdscale(bray_curtis, k=k, eig=T)
points <- pcoa$points
eig <- pcoa$eig
points <- as.data.frame(points)
colnames(points) <- c("x", "y")

#merge design information with coordinates
points <- cbind(points, d[match(rownames(points), d$SampleID), ])

points$Microbe<- factor(points$Microbe, levels=shapes$group)
points$Condition <- factor(points$Condition, levels=colors$group)

# plot
p <- ggplot(points, aes(x=x, y=y, color=Condition, shape=Microbe))+
  geom_point(alpha=1, size=6) +
  scale_colour_manual(values=as.character(colors$color)) +
  scale_shape_manual(values=shapes$shape) +
  labs(x=paste("PCoA 1 (", format(100 * eig[1] / sum(eig), digits=4), "%)", sep=""),
       y=paste("PCoA 2 (", format(100 * eig[2] / sum(eig), digits=4), "%)", sep="")) + 
  main_theme +
  theme(legend.position="top")

##to calculate input for SuppFig4c
#write files to read them as ASV
write.table(asv_raref, "asv_raref_forenrich.txt", sep="\t")
write.table(d, "d_forenrich.txt", sep="\t")

library('tidyverse')
library('magrittr')
library('DESeq2')
library('sva')

asvRaw <- read_tsv('asv_raref_forenrich.txt')
expDesign <- read_tsv('d_forenrich.txt') 

countData <- asvRaw %>%
  mutate_all(~ifelse(. == 0, 1, .)) %>%
  column_to_rownames('ASV') %>% ## add small value
  select(expDesign$SampleID) %>%
  set_colnames(str_replace_all(colnames(.), '\\.', '_')) %>%
  set_rownames(rownames(asvRaw))

designData <- expDesign %>%
  mutate(treatment = Condition %>% str_replace('-', '_')) %>%
  column_to_rownames('SampleID') %>%
  set_rownames(str_replace_all(rownames(.), '\\.', '_'))

## check
colnames(countData) == rownames(designData)

asvres <- DESeqDataSetFromMatrix(countData,
                                 designData,
                                 ~Condition_Microbe)

design(asvres) <- ~ Condition_Microbe
asvres <- DESeq(asvres)

## check groups
resultsNames(asvres)

cond <- list(c('Repopulated_Italian', 'Control_Italian'),
             c('Repopulated_Swedish', 'Control_Swedish'))

resRaw <- lapply(cond,
                 function(x) {
                   asvres %>%
                     results(contrast = c('Condition_Microbe', x)) %T>%
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

write.table(resRaw, "enriched_raw_repop_autoclaved.txt", sep="\t")
write.table(res, "enriched_res_repop_autoclaved.txt", sep="\t")

##calculated relative abundances of ASVs
asv_table_norm <- apply(asv_table, 2, function(x) x/sum(x))

#remove low abundant ASV
threshold <- .05
idx <- rowSums(asv_table_norm * 100 > threshold) >= 1
asv_table <- asv_table[idx, ]
asv_table_norm <- asv_table_norm[idx, ]

#change format to long version
otu_long <- melt(asv_table_norm, id.vars = "Group.1", variable.name = "Strain")

#write dataframe manually add design + taxnomic information, and leave only those ASVs enriched in the step before
#bacteria
otu_long<- read.table("long_asv_table_norm_enriched_b5.txt", header=TRUE, sep="\t")
#fungi
otu_long<- read.table("long_asv_table_norm_enriched_its1.txt", header=TRUE, sep="\t")

#calculate mean across samples and standard error
sd<- ddply(otu_long, c("Microbe", "Condition","ASV", "Phylum"), summarise, N=length(value), mean=mean(value), sd=sd(value), se=sd/sqrt(N))

colors <- data.frame(group=c("Control", "Repopulated"),
                     color=c("#000000","#808080"))		

#plot
p<- ggplot(sd, aes(x = ASV, y = mean, fill= Condition)) +     geom_bar(stat = "identity", colour="black", position=position_dodge(0.9))+
  scale_fill_manual(values=as.character(colors$color)) +
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.1, position=position_dodge(0.9))+
  theme(axis.text.x = element_text(size=10, angle=45))	 
p+facet_grid(Microbe~Phylum, scales="free_x", space = "free_x")


