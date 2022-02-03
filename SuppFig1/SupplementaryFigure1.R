##load data
design<- read.table("design_controls.txt", sep="\t", header=TRUE)
#for bacteria
asv_table<- read.table("otu_table_controls_b5.txt", header=TRUE, sep="\t", check.names=FALSE)
#for fungi
asv_table<- read.table("otu_table_controls_its1.txt", header=TRUE, sep="\t", check.names=FALSE)

library(ggplot2)
library("GUniFrac")

##rarefy ASV table
asv_raref <- Rarefy(t(asv_table), 1000)
asv_raref <- t(asv_raref$otu.tab.rff)

##select only control samples
d <- design[design$diversity %in% c("native", "repopulated", "soilwash"), ]

idx <- colnames(asv_raref) %in% d$SampleID

##calculate Bray Curtis dissimilarities
bray_curtis <- vegdist(t(asv_raref[, idx]), method="bray")
bray_curtis<- as.matrix(bray_curtis)

colors <- data.frame(group=c("native", "repopulated", "soilwash"),
                     color=c("#000000","#808080", "#1ea2a4"))		
shapes <- data.frame(group=c("Italian","Swedish"),
                     shape=c(16, 17))	

##caclulate coordinates of samples based on Bray-Curtis dissimilarities
k <- 2
pcoa <- cmdscale(bray_curtis, k=k, eig=T)
points <- pcoa$points
eig <- pcoa$eig
points <- as.data.frame(points)
colnames(points) <- c("x", "y")

#merge design information with coordinates
points <- cbind(points, d[match(rownames(points), d$SampleID), ])
points$Microbe<- factor(points$Microbe, levels=shapes$group)
points$diversity <- factor(points$diversity, levels=colors$group)

# plot Supplementary Figure 1c

p <- ggplot(points, aes(x=x, y=y, color=diversity, shape=Microbe))+
  geom_point(alpha=1, size=6) +
  scale_colour_manual(values=as.character(colors$color)) +
  scale_shape_manual(values=shapes$shape) +
  labs(x=paste("PCoA 1 (", format(100 * eig[1] / sum(eig), digits=4), "%)", sep=""),
       y=paste("PCoA 2 (", format(100 * eig[2] / sum(eig), digits=4), "%)", sep="")) + 
  main_theme +
  theme(legend.position="top")
  
##calculate shannon diversity

shannon<- diversity(asv_raref, index = "shannon", MARGIN = 2, base = exp(1))
write.table(shannon, "shannon.txt", sep="\t")

##add a new column to the design file and load it again

design<- read.table("design_controls.txt", header=TRUE, sep="\t")

#rearrange factors in design file
design$diversity<- factor(design$diversity, levels=c("native", "soilwash","repopulated"))

#plot Supplementary Figure 1b
p<- ggplot(design, aes(x=diversity, y=shannon, fill=diversity))+
  scale_fill_manual(values=as.character(colors$color)) +
  geom_boxplot()
p+facet_grid(~Microbe)

#calculate significant differences between shannon indexes
#subset data by microbial group
idx<- design$Microbe %in% ("Swedish")
d_swe<- design[idx,]

idx<- design$Microbe %in% ("Italian")
d_ita<- design[idx,]

#use kruskal wallis test for significant differentes
library('agricolae')
kruskal(d_swe$shannon, d_swe$diversity, alpha=0.05, p.adj="bonferroni")$groups
kruskal(d_ita$shannon, d_ita$diversity, alpha=0.05, p.adj="bonferroni")$groups
