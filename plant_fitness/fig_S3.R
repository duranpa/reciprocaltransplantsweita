library(tidyverse)
library(cowplot)

# Data from the chamber experiment
gnoto <- read_csv(
  "plant_fitness/gnotobiotic_expt_fitness_data.csv",
  col_types = 'ffffffffdi'
)


sterilised <- list()

font_size= 0.7
par(mar = c(0,4,0,0))
plot(c(0,13), c(1,-4), type='n', axes=F, xlab = "", ylab="")
# Draw boxes under the plot
rect((1:12)-0.5, -0.5, (1:12)+0.5, -1, col = rep(c("#eb624c", "#1d3d90ff"), each=6))
rect((1:12)-0.5, -1,   (1:12)+0.5, -1.5,  col = rep(c("#eb624c", "#1d3d90ff"), each=3))
rect((1:12)-0.5, -1.5, (1:12)+0.5, -2, col = c('gray70',0,0))
rect((1:12)-0.5, -2,   (1:12)+0.5, -2.5, 
     col = c(0, 0, "#eb624c", 0, 0, "#1d3d90ff")
)
# Insert labels in the boxes
text(1:12, -0.75, rep(c("It", "Sw"), each= 6), cex=font_size)
text(1:12, -1.25, rep(c("It", "Sw"), each=3), cex=font_size)
text(1:12, -1.75, c("No", "Yes", "Yes"), cex=font_size)
text(1:12, -2.25, c("-", "-", "It", "-", "-", "Sw"), cex=font_size)

text(0.4, -0.75, "Chamber",    xpd=NA, adj = c(1,0.5), cex=font_size)
text(0.4, -1.25, "Soil",       xpd=NA, adj = c(1,0.5), cex=font_size)
text(0.4, -1.75, "Sterilised", xpd=NA, adj = c(1,0.5), cex=font_size)
text(0.4, -2.25, "Inoculum",   xpd=NA, adj = c(1,0.5), cex=font_size)

sterilised$trt<- recordPlot()


sterilised$interactions <- gnoto %>% 
  filter(! trt %in% c(4,7, 15, 19)) %>% 
  group_by(chamber, soil, autoclaved, inoculum, genotype) %>% 
  summarise(
    mean = mean(fruits_per_seedling)
  ) %>% 
  mutate(
    Soil = ifelse(soil == "Italy", "Italian soil", "Swedish soil"),
    Genotype = ifelse(genotype == "It", "Italian", "Swedish"),
    Treatment = ifelse(autoclaved == 0, "Native", "Sterile"),
    Treatment = ifelse(inoculum != "No", "Reinoculated", Treatment),
    Treatment = fct_relevel(Treatment, "Sterile", after = 2)
  ) %>% 
  rename(Chamber = chamber) %>%
  
  ggplot(aes(
    x = Chamber, y = mean,
    shape = Soil, colour = Genotype, group = paste(Genotype, Soil) 
  ))+
  geom_point(size=3) +
  geom_line() +
  facet_grid( Soil ~ Treatment) +
  theme_bw() +
  scale_colour_manual(values = c('#eb624c', '#1d3d90ff')) +
  labs(
    y = "Fruits per seedling planted"
  )+
  theme(
    legend.position = "right"
  ) +
  guides(
    colour = guide_legend(
      override.aes = list(linetype = 0, shape = 15)
    )
  )


plot_grid(
  sterilised$trt,
  sterilised$interactions,
  nrow = 2, ncol=1,
  rel_heights = c(1, 3)
)

ggsave(
  "plant_fitness/fig_S3.pdf",
  device = "pdf",
  width=18/2.54, height=16/2.54
)
