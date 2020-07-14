library(tidyverse)
library(sf)
library(here)

files <- list.files(here("data/shapefiles/nhgis_blocks"), pattern = ".shp$", full.names = TRUE)
names <- list.files(here("data/shapefiles/nhgis_blocks"), pattern = ".shp$", full.names = FALSE)


blkGrps <- st_read(here("data/geopackage/final_estimates.gpkg"), layer= "All_Estimates_Blk_Grps_QA")%>%
  st_drop_geometry()


tbl <- read.csv(here("data/tables/nhgis0247_ds172_2010_block.csv"))%>%
  select(GISJOIN,H7V001,IFC001)

colnames(tbl) <- c("GISJOIN","Population","Housing_Units")

for(n in 1:10){
  sf <- st_read(files[n])%>%
    mutate("BlkGrp_ID" = substr(GISJOIN,1,15))%>%
    left_join(tbl)
  
  State <- as.character(sf$STATEFP10[1])
  
  filt <- blkGrps%>%
    filter(STATEFP10 == State)%>%
    select(GISJOIN, Wells_HYBRD, Housing_Units)
  
  colnames(filt) <- c("GISJOIN","Wells_BlkGrp","HU_BlkGrp")
  
  sfOut <- sf%>%
    left_join(filt, by = c("BlkGrp_ID" = "GISJOIN"))%>%
    mutate("Wells" = round((Housing_Units/HU_BlkGrp)*Wells_BlkGrp))%>%
    mutate("Population_Served" = round((Population/Housing_Units))*Wells)%>%
    select(GISJOIN,Population,Housing_Units,Wells,Population_Served)

  st_write(sfOut, here("data/geopackage/final_estimates_blocks.gpkg"), layer= paste0(substr(names[n],1,2),"_Estimates_Blocks_QA"), append = FALSE)
  
}





