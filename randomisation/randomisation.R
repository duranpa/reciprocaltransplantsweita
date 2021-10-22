#' Tom Ellis, 5th October 2017
#' 
#' Script to randomise positions of soil type, soil wash, autoclave treatment
#' and plant genotype.

set.seed(47)

# Matrix of treatment combinations
trt <- data.frame(
  trt     = 1:22, # numerical code to indicate treatment label
  climate = rep(c("it", "sw"), each=11), # Swedish vs Italian climate
  soil    = rep(c(rep("it",4), rep("sw", 4), rep("peat",3)), 2), # Soil matrix
  sterile = rep(c(0,1,1,1,0,1,1,1,1,1,1),2), # Whether soils were autoclaved (1 = yes; 0 = no)
  tea     = rep(c("none","none","it","sw", "none","none","sw","it", "it", "sw", "none"), 2) # soil wash
)

# Expand to give one row per well
dt <- trt[rep(1:nrow(trt), each=64),]
# Assign each set of eight rows to a tub, with tub labels in a random order.
# Tubs 1 to 88 are in the Italian climate chamber
# Tubs 91 to 178 are in the Swedish chamber.
dt <- cbind(tub = c(rep(sample(1:88, 88,   replace=F), each=8),
                    rep(sample(91:178, 88, replace=F), each=8)),
            pos=rep(1:8, 22), dt)

#' There are four Italian and four Swedish genotypes
#' These full siblings from the same mother, so should be identical in principle
#' Randomise their positions within each tub
lines <- c("It15", "It24", "It32", "It41", "Sw7", "Sw11", "Sw43","Sw47")
line_samp <- c()
while(length(line_samp) < nrow(dt)) line_samp <- c(line_samp, sample(lines, 8, replace = F))
dt$genotype <- line_samp

write.csv(trt, file="randomisation/gnotobiotic_summary.csv", row.names = F)
write.csv(dt,  file="randomisation/gnotobiotic_expt.csv", row.names = F)

