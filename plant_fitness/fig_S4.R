library(tidyverse)
library(cowplot)

# Data from the field experiment
field <- read_csv(
  "plant_fitness/field_expt_fitness_data.csv", col_types = 'ffffffi'
)
# Data from the chamber experiment
gnoto <- read_csv(
  "plant_fitness/gnotobiotic_expt_fitness_data.csv",
  col_types = 'ffffffffdi'
)

# Create illustration of treatments for figure S4A

field_native <- list()

font_size= 0.7
par(mar = c(0,4,0,0))
plot(c(0,5), c(0,-3), type='n', axes=F, xlab = "", ylab="")
# Draw boxes under the plot
rect((1:4)-0.5, -0.5, (1:4)+0.5, -1, col = rep(c("#eb624c", "#1d3d90ff"), each=2))
rect((1:4)-0.5, -1,   (1:4)+0.5, -1.5,  col = rep(c("#eb624c", "#1d3d90ff"), each=1))
rect((1:4)-0.5, -1.5, (1:4)+0.5, -2, col = 'gray70')
rect((1:4)-0.5, -2,   (1:4)+0.5, -2.5, col = 0)
# Insert labels in the boxes
text(1:4, -0.75, rep(c("It", "Sw"), each= 2), cex=font_size)
text(1:4, -1.25, rep(c("It", "Sw"), each=1), cex=font_size)
text(1:4, -1.75, "No", cex=font_size)
text(1:4, -2.25, "-", cex=font_size)

text(0.4, -0.75, "Chamber",   xpd=NA, adj = c(1,0.5), cex=font_size)
text(0.4, -1.25, "Soil",      xpd=NA, adj = c(1,0.5), cex=font_size)
text(0.4, -1.75, "Sterilised",xpd=NA, adj = c(1,0.5), cex=font_size)
text(0.4, -2.25, "Inoculum",      xpd=NA, adj = c(1,0.5), cex=font_size)

field_native$trt_native <- recordPlot()


# Create illustration of treatments for figure S4B
font_size= 0.7
par(mar = c(0,4,0,0))
plot(c(0,5), c(0,-3), type='n', axes=F, xlab = "", ylab="")
# Draw boxes under the plot
rect((1:4)-0.5, -0.5, (1:4)+0.5, -1, col = rep(c("#eb624c", "#1d3d90ff"), each=2))
rect((1:4)-0.5, -1,   (1:4)+0.5, -1.5,  col = rep(c("#eb624c", "#1d3d90ff"), each=1))
rect((1:4)-0.5, -1.5, (1:4)+0.5, -2, col = 'gray70')
rect((1:4)-0.5, -2,   (1:4)+0.5, -2.5, col = 0)
# Insert labels in the boxes
text(1:4, -0.75, rep(c("It", "Sw"), each= 2), cex=font_size)
text(1:4, -1.25, rep(c("It", "Sw"), each=1), cex=font_size)
text(1:4, -1.75, "No", cex=font_size)
text(1:4, -2.25, "-", cex=font_size)

text(0.4, -0.75, "Location",   xpd=NA, adj = c(1,0.5), cex=font_size)
text(0.4, -1.25, "Soil",      xpd=NA, adj = c(1,0.5), cex=font_size)
text(0.4, -1.75, "Sterilised",xpd=NA, adj = c(1,0.5), cex=font_size)
text(0.4, -2.25, "Inoculum",      xpd=NA, adj = c(1,0.5), cex=font_size)

field_native$trt_field<- recordPlot()


field_native$int_native <- gnoto %>%
  filter(soil %in% c("Italy", "Sweden"), autoclaved == 0) %>% 
  group_by(chamber, soil, genotype) %>% 
  summarise(
    mean = mean(fruits_per_seedling)
  ) %>% 
  mutate(
    Soil = ifelse(soil == "Italy", "Italian soil", "Swedish soil"),
    Genotype = ifelse(genotype == "It", "Italian", "Swedish")
  ) %>% 
  ggplot(aes(
    x = chamber, y = mean, colour = Genotype,
    shape = Soil, group= paste(Genotype, Soil),
  )) +
  geom_point(size = 3) + 
  geom_line() +
  theme_bw() + 
  scale_colour_manual(values = c('#eb624c', '#1d3d90ff')) +
  labs(
    x = "Climate chamber",
    y = "Fruits per seedling planted"
  ) + 
  theme(legend.position="none")

field_native$int_field <- field %>% 
  group_by(location, soil, genotype) %>% 
  summarise(
    mean = mean(fruits_per_seedling, na.rm=TRUE)
  ) %>% 
  mutate(
    Soil = ifelse(soil == "It", "Italian soil", "Swedish soil"),
    Genotype = ifelse(genotype == "Italy", "Italian", "Swedish")
  ) %>% 
  ggplot(aes(
    x = location, y = mean, colour = Genotype,
    shape = Soil, group= paste(Genotype, Soil),
  )) +
  geom_point(size = 3) + 
  geom_line() +
  theme_bw() + 
  scale_colour_manual(values = c('#eb624c', '#1d3d90ff')) +
  labs(
    x = "Location",
    y = "Fruits per seedling planted"
  ) +
  theme(legend.position="none")

plot_grid(
  field_native$trt_native,
  field_native$trt_field,
  field_native$int_native,
  field_native$int_field,
  ncol=2, nrow=2,
  labels = "AUTO",
  heights = c(1,2)
) +
  guides(
    colour = guide_legend(override.aes = list(linetype = 0, shape = 15))
  )

ggsave(
  "plant_fitness/fig_S4.pdf",
  device = "pdf",
  width=16.9, height  = 16,
  units = "cm"
)

