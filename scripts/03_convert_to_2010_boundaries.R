library(sf)
library(tidyverse)
library(raster)
library(here)

# Import the 2010 boundaries 
sf <- st_read(here("data/geopackage/nhgis_block_groups.gpkg"),layer = "US_block_groups_2010")%>%
  st_transform(crs = 2163)

ri <- sf%>%
  filter(STATEFP10 == "44")

rrr <- 

# We created the rasters by county, but we want to do the conversions at the state level
# so we need to mosaic together all of the rasters by state

# Create a list of state fips codes
states <- levels(sf$STATEFP10)

#################
# 1990 Well Use #
#################

# Link: https://gis.stackexchange.com/questions/226351/combine-multiple-partially-overlapping-rasters-into-a-single-raster-in-r

for(n in 1:nrow(files)){
  r <- raster(files$file[n])
  projection(r) <- "+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +a=6370997 +b=6370997 +units=m +no_defs"
  origin(r) <- c(0,0)
  writeRaster(r,paste0(here("temp"),"/rast_",n))
}

list <- list.files(here("temp"),full.names = TRUE,pattern = '.grd$')

mosaicList <- function(rasList){
  
  #Internal function to make a list of raster objects from list of files.
  ListRasters <- function(list_names) {
    raster_list <- list() # initialise the list of rasters
    for (i in 1:(length(list_names))){ 
      grd_name <- list_names[i] # list_names contains all the names of the images in .grd format
      raster_file <- raster::raster(grd_name)
    }
    raster_list <- append(raster_list, raster_file) # update raster_list at each iteration
  }
  
  #convert every raster path to a raster object and create list of the results
  raster.list <-sapply(rasList, FUN = ListRasters)
  
  # edit settings of the raster list for use in do.call and mosaic
  names(raster.list) <- NULL
  #####This function deals with overlapping areas
  raster.list$fun <- sum
  
  #run do call to implement mosaic over the list of raster objects.
  mos <- do.call(raster::merge, raster.list)
  
  #set crs of output
  crs(mos) <- crs(x = raster(rasList[1]))
  return(mos)
}


try <- mosaicList(list)