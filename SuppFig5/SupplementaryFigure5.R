

##Supplementary Figure 5
##selected Chamber and genotype for constraining Bray Curtis distances so that their effect is more apparent

design<- read.table("design_filt2.txt", header=TRUE, sep="\t", check.names=FALSE)
#for bacteria
asv_table<- read.table("asv_table_b5.txt", header=TRUE, sep="\t", check.names=FALSE)
#for fungi
asv_table<- read.table("asv_table_its1.txt", header=TRUE, sep="\t", check.names=FALSE)

# normalize otu tables
library(ggplot2)
library("GUniFrac")

asv_raref <- Rarefy(t(asv_table), 1000)
asv_raref <- t(asv_raref$otu.tab.rff)

#subset treatments of interest
d <- design[design$Condition %in% c("Repopulated", "Repopulated_changed_climate", "Changed_soil", "Changed_soil_climate"), ]
d<- d[d$Fraction %in% c("Soil"), ]
d<- d[d$Planted %in% c("Planted"), ]

idx <- colnames(asv_raref) %in% d$SampleID

bray_curtis <- vegdist(t(asv_raref[, idx]), method="bray")
bray_curtis<- as.matrix(bray_curtis)

#remove samples in design file which are not in Bray Curtis
idx<- d$SampleID %in% colnames(bray_curtis)
d<- d[idx,]

source("cpcoa.func.R")

#calculate variance driven by Chamber+Genotype removing all other factors
sqrt_transform <- T
capscale.rate <- capscale(bray_curtis ~ Chamber+Genotype +Condition(Soil+Wash+Library),
                          data=d, add=F, sqrt.dist=sqrt_transform)

perm_anova.rate <- anova.cca(capscale.rate)
print(perm_anova.rate)

# generate variability tables and calculate confidence intervals for the variance

var_tbl.rate <- variability_table(capscale.rate)

eig <- capscale.rate$CCA$eig

variance <- var_tbl.rate["constrained", "proportion"]
p.val <- perm_anova.rate[1, 4]

#substract samples coordinates 
points <- capscale.rate$CCA$wa[,1:2]
points <- as.data.frame(points)
colnames(points) <- c("x", "y")

colors <- data.frame(group=c("Italian", "Swedish"),
                     color=c("#eb624c", "#1d3d90"))		
shapes <- data.frame(group=c("Italian","Swedish"),
                     shape=c(16, 17))	

#march coordinates with design file
points <- cbind(points, d[match(rownames(points), d$SampleID), ])

#plot
p <- ggplot(points, aes(x=x, y=y, color=Genotype, shape=Chamber)) +
  geom_point(alpha=.7, size=6) +
  scale_colour_manual(values=as.character(colors$color)) +
  scale_shape_manual(values=shapes$shape)+
  labs(x=paste("cPCoA 1 (", format(100 * eig[1] / sum(eig), digits=4), "%)", sep=""),
       y=paste("cPCoA 2 (", format(100 * eig[2] / sum(eig),	 digits=4), "%)", sep="")) + 
  ggtitle(paste(format(100 * variance, digits=2), " % of variance; p=",
                format(p.val, digits=2),
                sep="")) +
  theme(legend.position="right")+ main_theme

