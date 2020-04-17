library(sf)
library(dplyr)
library(here)
library(units)






### 1990 Block Groups ###
sf <- st_read(here("data/geopackage/nhgis_block_groups.gpkg"), layer = "US_block_groups_1990")
# Project to equal area
sfEA <- st_transform(sf, crs = 2163)

# Calculate area of each block group in square km
sfEA$Area <- st_area(sfEA)%>%
  set_units(km^2)

# Calculate well density
sfEA$well_Density <- (sfEA$Drill_sow+sfEA$Dug_sow) / sfEA$Area

# Get bounding box of polygons
extent <- st_bbox(sfEA) 

# Determine columns and rows based on the extent and a 20 meter cell-size
rows <- round(as.numeric(extent$ymax - extent$ymin)/20,0)
cols <- round(as.numeric(extent$xmax - extent$xmin)/20,0)

r <- raster(ncol = cols, nrow = rows)
extent(r) <- extent(sfEA)

plot(r)
