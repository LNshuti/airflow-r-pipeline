library(tigris)
library(ggplot2)

tn_roads <- roads(state = "Tennessee", county = "Davidson")

ggplot(tn_roads) + 
  geom_sf() + 
  theme_void()
