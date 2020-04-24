library(sf)
library(dplyr)
library(raster)
library(here)
library(units)

########################################################################################




### 1990 Block Groups ###
sf <- st_read(here("data/geopackage/nhgis_block_groups.gpkg"), layer = "US_block_groups_1990")
# Project to equal area
sfEA <- st_transform(sf, crs = 2163)

# Calculate area of each block group in square km
sfEA$Area <- st_area(sfEA)%>%
  set_units(km^2)

# Calculate Well Density
sfEA$well_Density <- (sfEA$Drill_sow+sfEA$Dug_sow) / sfEA$Area

# Calculate Housing Unit Density
sfEA$hu_Density <- sfEA$Housing_Units / sfEA$Area

##############################################################################################
# The next step is to rasterize the data. This is a very computationally intense operation   # 
# I have listed two options below. The first option is to try to do it all at once, but only #
# attempt this if you are using a very powerful computer. The second option will iterate and #
# rasterize one county at a time, then mosaic everything back together.                      #
##############################################################################################

####### 1990 Well Density (ALL AT ONCE) #######

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

# --------------------------------------------------------------- #

####### 1990 Well Density ONE COUNTY AT A TIME #######

# We'll only consider polygons with values > 0 to speed things up a bit
nonzero <- sfEA%>%
  filter(as.numeric(well_Density) > 0)


# Create list of all county fips codes by creating a
# new column that combines the state and county fips codes
nonzero$STCO <- paste0(as.character(nonzero$ST_FIPS),as.character(nonzero$CO_FIPS)) 

# Then extract that column, strip away the geometries and convert to a list
counties <- nonzero%>%
  dplyr::select(STCO)%>%
  st_drop_geometry()%>%
  distinct()
counties <- split(counties$STCO, seq(nrow(counties)))

# convert to a character type to allow for filtering in the loop
nonzero$STCO <- as.character(nonzero$STCO)

# Create the for loop
for(n in counties){
  sub <- nonzero%>%
    filter(STCO == as.character(n)) # filter to a single county
  print(paste0("Starting ",n," at: ",Sys.time())) # Print the starting time
  extent <- st_bbox(sub) # get the extent of the polygons in your county to use to create the empty raster
  rows <- round(as.numeric(extent$ymax - extent$ymin)/20,0)  # calculate number of rows in the empty raster
  cols <- round(as.numeric(extent$xmax - extent$xmin)/20,0)  # calculate number of columns in the empty raster
  r <- raster(ncol = cols, nrow = rows) # create an empty raster with the calculated rows and columns
  extent(r) <- extent(sub) # Assign the extent of the empty raster to the extent of the county polygons
  rast <- rasterize(sub,r, field = 'well_Density') # Convert the polygons into a raster, using the newly created empty raster as a template
  writeRaster(rast, paste0(here("data/rasters/well_density_90"),"/well_density_90_",n,".tif")) # Write the raster to a tif file
  print(paste0("Finished ",n," at: ",Sys.time())) # Print the time each iteration finished
}

####################################################
# 1990 Housing Unit Density (ONE COUNTY AT A TIME) #
####################################################

# We'll only consider polygons with values > 0 to speed things up a bit
nonzero <- sfEA%>%
  filter(as.numeric(hu_Density) > 0)%>%
  arrange(as.numeric(as.character(ST_FIPS)))


# Create list of all county fips codes
nonzero$STCO <- paste0(as.character(nonzero$ST_FIPS),as.character(nonzero$CO_FIPS))

counties <- nonzero%>%
  dplyr::select(STCO)%>%
  st_drop_geometry()%>%
  distinct()
counties <- split(counties$STCO, seq(nrow(counties)))


nonzero$STCO <- as.character(nonzero$STCO)

# Create for loop
for(n in counties){
  sub <- nonzero%>%
    filter(STCO == as.character(n))
  print(paste0("Starting ",n," at: ",Sys.time()))
  extent <- st_bbox(sub)
  rows <- round(as.numeric(extent$ymax - extent$ymin)/20,0)
  cols <- round(as.numeric(extent$xmax - extent$xmin)/20,0)
  r <- raster(ncol = cols, nrow = rows)
  extent(r) <- extent(sub)
  rast <- rasterize(sub,r, field = 'hu_Density')
  writeRaster(rast, paste0(here("data/rasters/hu_density_90"),"/hu_density_90_",n,".tif")) # Write the raster to a folder
  print(paste0("Finished ",n," at: ",Sys.time()))
  print("---")
}


# -------------------------------------------------------------------------------------- #

#####################
# 2000 Block Groups #
#####################

### Import 2000 Block Groups ###
sf <- st_read(here("data/geopackage/nhgis_block_groups.gpkg"), layer = "US_block_groups_2000")
# Project to equal area
sfEA <- st_transform(sf, crs = 2163)

# Calculate area of each block group in square km
sfEA$Area <- st_area(sfEA)%>%
  set_units(km^2)

# Calculate Housing Unit Density
sfEA$hu_Density <- sfEA$Housing_Units / sfEA$Area

####################################################
# 2000 Housing Unit Density (ONE COUNTY AT A TIME) #
####################################################

# We'll only consider polygons with values > 0 to speed things up a bit
nonzero <- sfEA%>%
  filter(as.numeric(hu_Density) > 0)


# Create list of all county fips codes
nonzero$STCO <- paste0(as.character(nonzero$ST_FIPS),as.character(nonzero$CO_FIPS))

counties <- nonzero%>%
  dplyr::select(STCO)%>%
  st_drop_geometry()%>%
  distinct()
counties <- split(counties$STCO, seq(nrow(counties)))


nonzero$STCO <- as.character(nonzero$STCO)

# Create for loop
for(n in counties){
  sub <- nonzero%>%
    filter(STCO == as.character(n))
  print(paste0("Starting ",n," at: ",Sys.time()))
  extent <- st_bbox(sub)
  rows <- round(as.numeric(extent$ymax - extent$ymin)/20,0)
  cols <- round(as.numeric(extent$xmax - extent$xmin)/20,0)
  r <- raster(ncol = cols, nrow = rows)
  extent(r) <- extent(sub)
  rast <- rasterize(sub,r, field = 'hu_Density')
  writeRaster(rast, paste0(here("data/rasters/hu_density_00"),"/hu_density_00_",n,".tif")) # Write the raster to a folder
  print(paste0("Finished ",n," at: ",Sys.time()))
}
