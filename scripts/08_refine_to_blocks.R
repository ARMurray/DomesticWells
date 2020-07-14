library(tidyverse)
library(sf)
library(here)
library(units)

files <- list.files(here("data/shapefiles/nhgis_blocks"), pattern = ".shp$", full.names = TRUE)
names <- list.files(here("data/shapefiles/nhgis_blocks"), pattern = ".shp$", full.names = FALSE)


blkGrps <- st_read(here("data/geopackage/final_estimates.gpkg"), layer= "All_Estimates_Blk_Grps_QA")%>%
  st_drop_geometry()%>%
  mutate(STATEFP10 = as.character(STATEFP10))


tbl <- read.csv(here("data/tables/nhgis0247_ds172_2010_block.csv"))%>%
  select(GISJOIN,H7V001,IFC001)

colnames(tbl) <- c("GISJOIN","Population","Housing_Units")

for(n in 1:length(files)){
  print(paste0("Starting ", substr(names[n],1,2)," at: ",Sys.time()))
  sf <- st_read(files[n])%>%
    mutate("BlkGrp_ID" = substr(GISJOIN,1,15))%>%
    left_join(tbl)
  
  sf$Area <- st_area(sf)%>%
    set_units(km^2)
  
  StateNum <- as.character(sf$STATEFP10[1])
  
  filt <- blkGrps%>%
    filter(STATEFP10 == as.character(StateNum))%>%
    select(GISJOIN,GEOID,State,County, Housing_Units,Well_Density_2010_Est,
           Wells_2010_Est,Method,Wells_1990,Wells_2000_Est,Area)
  
  colnames(filt) <- c("GISJOIN","GEOID","State","County","HU_BlkGrp",
                      "Well_Density_BlkGrp2010","Wells_2010_BlkGrp",
                      "Method","Wells_1990_BlkGrp","Wells_2000_BlkGrp","Area_BlkGrp")
  
  sfOut <- sf%>%
    left_join(filt, by = c("BlkGrp_ID" = "GISJOIN"))%>%
    mutate("Wells" = round((Housing_Units/HU_BlkGrp)*Wells_2010_BlkGrp))%>%
    mutate("Population_Served" = round((Population/Housing_Units))*Wells,
           "Percent_Served" = Population_Served/Population,
           "GEOID" = paste0(substr(GISJOIN,2,3), substr(GISJOIN,5,7), substr(GISJOIN,9,18)),
           "Wells_1990_Est" = (Wells_1990_BlkGrp/Area_BlkGrp)*as.numeric(Area),
           "Wells_2000_Est" = (Wells_2000_BlkGrp/Area_BlkGrp)*as.numeric(Area))%>%
    select(GEOID,State,County,Population,Housing_Units,Well_Density_BlkGrp2010,
           Wells,Method,Percent_Served,Population_Served,Wells_1990_Est,Wells_2000_Est)%>%
    st_transform(crs = 4326)

  colnames(sfOut) <- c("GEOID","State","County","Population_Block","Housing_Units_Block","Well_Density_2010_Est","Wells_2010_Est","Method",
                       "Well_Usage_Rate_Est","Population_Served_Est","Wells_1990_Est","Wells_2000_Est","geometry")
  st_write(sfOut, here("data/geopackage/final_estimates_blocks.gpkg"), layer= paste0(substr(names[n],1,2),"_Estimates_Blocks_QA"), append = FALSE)
  
  print(paste0("Finished ", substr(names[n],1,2)," at: ",Sys.time()))
}


# COLUMN NAMES FOR BLOCKS

# GEOID
# STATE
# COUNTY
# POPULATION (BLOCK)
# HOUSING UNITS (Block)
# WELL DENSITY
# 2010 WELLS (EST)
# METHOD
# WELL USAGE RATE (EST)
# POPULATION SERVED (EST)
# 1990 WELLS (EST)
# 2000 WELLS (EST)


