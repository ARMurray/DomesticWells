library(rgdal)
library(sf)
library(here)

# Create a list of all of the full pathnames of the shapefiles
filepaths <- list.files(here("data/shapefiles/"), pattern = ".shp$", full.names = TRUE)

# Create a list of all of the short names of the shapefiles
fileNames <- list.files(here("data/shapefiles/"), pattern = ".shp$")

# Iterate through the files to import the shapefile
# and export a geopackage of the same name

for(n in 1:length(filepaths)){
  shp <- st_read(filepaths[n])
  shortName <- substr(fileNames[n],1,nchar(fileNames[n])-4)
  st_write(shp,dsn = paste0(here("data/geopackage")),layer = shortName, driver = "GPKG")
}


cnty <- st_read(filepaths[5])
st_write(cnty,here("data/geopackage/county.gpkg"))

writeOGR(cnty, dsn = here("data/geopackage/county.gpkg"), layer = "counties", driver = "GPKG")

writeOGR(cities, dsn = outname, layer = "cities", driver = "GDB")
