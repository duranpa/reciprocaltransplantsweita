library(tidyverse)
library(ggpubr)

reinoculated <- list() # empty list to store the subplots

# Cartoon illustrating the treatments being compared
font_size= 0.7
par(mar = c(0,4,0,0))
plot(c(0,9), c(0,-3), type='n', axes=F, xlab = "", ylab="")
# Draw boxes under the plot
rect((1:8)-0.5, -0.5, (1:8)+0.5, -1, col = rep(c("#eb624c", "#1d3d90ff"), each=4))
rect((1:8)-0.5, -1,   (1:8)+0.5, -1.5,  col = rep(c("#eb624c", "#1d3d90ff"), each=2))
rect((1:8)-0.5, -1.5, (1:8)+0.5, -2, col = 0)
rect((1:8)-0.5, -2,   (1:8)+0.5, -2.5, col = c("#eb624c", "#1d3d90ff", "#eb624c", "#1d3d90ff"))
# Insert labels in the boxes
text(1:8, -0.75, rep(c("It", "Sw"), each= 4), cex=font_size)
text(1:8, -1.25, rep(c("It", "Sw"), each=2), cex=font_size)
text(1:8, -1.75, c("Yes", "Yes", "Yes", "Yes"), cex=font_size)
text(1:8, -2.25, c("It", "Sw", "It", "Sw"), cex=font_size)

text(0.4, -0.75, "Chamber",   xpd=NA, adj = c(1,0.5), cex=font_size)
text(0.4, -1.25, "Soil",      xpd=NA, adj = c(1,0.5), cex=font_size)
text(0.4, -1.75, "Sterilised",xpd=NA, adj = c(1,0.5), cex=font_size)
text(0.4, -2.25, "Inoculum",      xpd=NA, adj = c(1,0.5), cex=font_size)

reinoculated$trt<- recordPlot()

# Variance explained for factors explaining >0% of the variance
reinoculated$pve  <- read_csv(
  "plant_fitness/ANOVA_results_reinoculated_soils.csv"
  ) %>% 
  filter(
    `Pct of Total` > 0,
    `Random Effect` != 'Total'
  ) %>% 
  mutate(`Random Effect` = fct_relevel(
    `Random Effect`,
    "Chamber", "Soil", "Inoculum",
    "Chamber x Inoculum", "Genotype x Chamber",
    "Genotype x Chamber x Soil"
  )) %>% 
  ggplot(aes(x = `Random Effect`, y = `Pct of Total`) ) +
  geom_col() +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.title.x=element_blank()) +
  labs(
    y = "% var. explained"
  )

# Interaction plots
pd = position_dodge(0.3)
reinoculated$interaction <- read_csv(
  "plant_fitness/gnotobiotic_expt_fitness_data.csv",
  col_types = 'ffffffffdi'
) %>% 
  filter(soil %in% c("Italy", "Sweden"), inoculum %in% c("Italy", "Sweden"), autoclaved == 1) %>% 
  group_by(chamber, soil, inoculum, genotype, autoclaved) %>% 
  summarise(
    mean = mean(fruits_per_seedling),
    sd   = sd(fruits_per_seedling),
    se    = sd / sqrt(n()-1)
  ) %>% 
  mutate(
    # Create some variables with nice titles and entries for plotting
    Soil = ifelse(soil == "Italy", "Italian soil", "Swedish soil"),
    Genotype = ifelse(genotype == "It", "Italian", "Swedish"),
    Inoculum = ifelse(inoculum == "Italy", "Italian", "Swedish")
  ) %>% 
  ggplot(aes(
    x = chamber, y = mean, colour = Genotype,
    shape = Inoculum, group= paste(Genotype, Inoculum),
  )) +
  geom_point(size = 3, position = pd) + 
  geom_line(position = pd) +
  geom_errorbar(
    aes(ymin=mean-se, ymax=mean+se), width=.1, position = pd) +
  facet_grid(~ Soil) +
  theme_bw() + 
  scale_colour_manual(values = c('#eb624c', '#1d3d90ff')) +
  theme(
    legend.position = "bottom",
    legend.title = element_text(size=8),
    legend.text = element_text(size=8)
  )+
  labs(
    x = "Climate chamber",
    y = "Fruits per seedling planted"
  )+
  guides(
    color=guide_legend(
      nrow=2,
      byrow=TRUE,
      override.aes = list(linetype = 0, shape = 15)),
    shape=guide_legend(nrow=2, byrow=TRUE)
  )

# Stitch the plots together and save
ggarrange(
  reinoculated$trt,
  reinoculated$pve,
  reinoculated$interaction,
  nrow=3, labels = "AUTO", heights = c(1,2,2))

ggsave(
  "plant_fitness/fig2.pdf",
  device = "pdf",
  width = 8,
  height = 21, 
  units = "cm"
)
