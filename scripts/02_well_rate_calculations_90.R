library(sf)
library(dplyr)
library(ggplot2)
library(here)

# Import prepared 1990 layer
sf <- st_read(here("data/geopackage/nhgis_block_groups.gpkg"), layer = "US_block_groups_1990")%>%
  mutate(pct_Well = 100 * (Drill_sow + Dug_sow)/(Public_sow+Drill_sow+Dug_sow+Other_sow))

# Replace NA values with 0
sf$pct_Well[is.na(sf$pct_Well)] <- 0


# Save the layer by overwriting the original with the new column
st_write(sf,here("data/geopackage/nhgis_block_groups.gpkg"), layer = "US_block_groups_1990",append = FALSE)







#### PLOTS ####


# Histogram
sf%>%
  filter(pct_Well>0)%>%
  ggplot()+
    geom_histogram(aes(pct_Well/100),color = "#ffffff",fill="#4B9CD3", bins = 20)+
    scale_x_continuous(labels = scales::percent)+
    scale_y_continuous(labels=function(x) format(x, big.mark = ",", scientific = FALSE))+
    labs(title = "Percent of Housing Units Using Wells (1990 Block Groups)",
         x = " Percent Using Wells",
         y = "Number of Block Groups")

zero <- sf%>%
  filter(pct_Well==0)
