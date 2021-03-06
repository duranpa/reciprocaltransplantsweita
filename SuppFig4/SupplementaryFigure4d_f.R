#load data
#for bacteria
design<- read.table("design_b5.txt", header=TRUE, sep="\t", check.names = FALSE)
asv_table<- read.table("otu_table_check_b5.txt", header=TRUE, sep="\t", check.names = FALSE)

#for fungi 
design<- read.table("design_its1.txt", header=TRUE, sep="\t", check.names = FALSE)
asv_table<- read.table("otu_table_check_its1.txt", header=TRUE, sep="\t", check.names = FALSE)

#select samples to be analyzed
d<- design[design$Line2 %in% c("Swedish", "Italian"), ]
d<- d[d$Fraction %in% c("Soil"),]

asv_raref <- Rarefy(t(asv_table), 1000)
asv_raref <- t(asv_raref$otu.tab.rff)

idx <- colnames(asv_raref) %in% d$SampleID

bray_curtis <- vegdist(t(asv_raref[, idx]), method="bray")
bray_curtis<- as.matrix(bray_curtis)

shapes <- data.frame(group=c("Italian_Italian", "Italian_Swedish", "Swedish_Italian", "Swedish_Swedish"),
                     shape=c(16, 17, 1, 2))					 
colors <- data.frame(group=c("Italian_Soil", "Swedish_Soil"),
                     color=c("#000000", "#000000"))
#calculate coordinates based on Bray Curtis distances
k <- 2
pcoa <- cmdscale(bray_curtis, k=k, eig=T)
points <- pcoa$points
eig <- pcoa$eig
points <- as.data.frame(points)
colnames(points) <- c("x", "y")

#merge coordinates with design information
points <- cbind(points, d[match(rownames(points), d$SampleID), ])

points$Climate_soil<- factor(points$Climate_soil, levels=shapes$group)
points$Soil_Fraction <- factor(points$Soil_Fraction, levels=colors$group)

# plot 
p <- ggplot(points, aes(x=x, y=y, color=Soil_Fraction, shape=Climate_soil))+
  geom_point(alpha=1, size=6) +
  scale_colour_manual(values=as.character(colors$color)) +
  scale_shape_manual(values=shapes$shape) +
  labs(x=paste("PCoA 1 (", format(100 * eig[1] / sum(eig), digits=4), "%)", sep=""),
       y=paste("PCoA 2 (", format(100 * eig[2] / sum(eig), digits=4), "%)", sep="")) + 
  main_theme +
  theme(legend.position="top")

#calculate variance explained by different factors
adonis(bray_curtis ~ Soil *Climate * Line2,      data = d, permutations = 999, method = "bray", strata = NULL) 

#plot variances
##substracted output information from adonis and created a dataframe with variance and design information

variance<- read.table("variance.txt", header=TRUE, sep="\t")
var<- variance[variance$Experiment %in% c("Field"), ]

p <- ggplot(var, aes(x=Factor, y=Variance)) +
  geom_bar(stat="identity")
p+facet_wrap(vars(Microbe), scales="free")+theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))
