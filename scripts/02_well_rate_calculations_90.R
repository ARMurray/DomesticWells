library(sf)
library(dplyr)
library(ggplot2)
library(here)

# Import prepared 1990 layer
sf <- st_read(here("data/geopackage/nhgis_block_groups.gpkg"), layer = "US_block_groups_1990")%>%
  mutate(Well_Rate = (Drill_sow + Dug_sow)/(Public_sow+Drill_sow+Dug_sow+Other_sow))

# Replace NA values with 0
sf$Well_Rate[is.na(sf$Well_Rate)] <- 0

# Histogram
sf%>%
  filter(Well_Rate>0)%>%
  ggplot()+
    geom_histogram(aes(Well_Rate),color = "#ffffff",fill="#4B9CD3", bins = 20)+
    scale_x_continuous(labels = scales::percent)+
    scale_y_continuous(labels=function(x) format(x, big.mark = ",", scientific = FALSE))+
    labs(title = "Percent of Housing Units Using Wells (1990 Block Groups)",
         x = " Percent Using Wells",
         y = "Number of Block Groups")

zero <- sf%>%
  filter(Well_Rate==0)
