library(sf)
library(dplyr)
library(raster)
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


# The next step is to rasterize the data. This is a very computationally intense operation
# I have listed two options below. The first option is to try to do it all at once, but only
# attempt this if you are using a very powerful computer. The second option will iterate and
# rasterize one state at a time, then mosaic everything back together.

####### ALL AT ONCE #######

# Get bounding box of polygons
#extent <- st_bbox(sfEA) 

# Determine columns and rows based on the extent and a 20 meter cell-size
#rows <- round(as.numeric(extent$ymax - extent$ymin)/20,0)
#cols <- round(as.numeric(extent$xmax - extent$xmin)/20,0)

# Create the empty raster
#r <- raster(ncol = cols, nrow = rows)
#extent(r) <- extent(sfEA)

# rasterize the entire country all at once.
#wellDensity_90 <- rasterize(sfEA,r, field = 'well_Density')


####### ONE STATE AT A TIME #######

# Create list of all state fips codes
states <- levels(sfEA$ST_FIPS)

# Create for loop
for(n in states){
  sub <- sfEA%>%
    filter(ST_FIPS == n)
  print(paste0("Starting ",n," at: ",Sys.time()))
  extent <- st_bbox(sub)
  rows <- round(as.numeric(extent$ymax - extent$ymin)/20,0)
  cols <- round(as.numeric(extent$xmax - extent$xmin)/20,0)
  r <- raster(ncol = cols, nrow = rows)
  extent(r) <- extent(sub)
  rast <- rasterize(sub,r, field = 'well_Density')
  writeRaster(rast, paste0(here("data/rasters/well_density_90"),"/well_density_90_",n,".tif")) # Write the raster to a folder
  print(paste0("Finished ",n," at: ",Sys.time()))
}
