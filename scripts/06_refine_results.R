#############################################################
# Here, we apply the five tests shown in our paper as a way #
# to parse out spatial inaacuracies which may have occured  #
# while reaggregating 1990 & 2000 boundaries to match 2010  #
# Census boundaries.                                        #
#############################################################

library(tidyverse)
library(sf)
library(here)
library(units)


# Import data set with final estimates
sf <- st_read(here("data/geopackage/final_estimates.gpkg"), layer= "All_Estimates_Blk_Grps")

df <- sf%>%
  st_drop_geometry()


# Test #1: (1)	Housing change from 1990 – 2000:  Realistic housing unit density change was 
# determined for block groups between 1990 and 2000 by identifying block groups which maintained 
# the exact same boundaries between census collection years and then finding the range of housing 
# unit density changes for these block groups. Due to the fact that census boundary files for 1990 
# and 2000 are slightly different, block groups were determined to be identical if they had less 
# than .1 percent change in land area between 1990 and 2000.

bg90 <- st_read(here("data/geopackage/nhgis_block_groups.gpkg"), layer = "US_block_groups_1990")

sel90 <- bg90%>%
  mutate(Area_90 = st_area(bg90)%>%
           set_units(km^2))%>%
  select(GISJOIN,Housing_Units,Area_90)
colnames(sel90) <- c("GISJOIN90","HU_90","Area_90","geom")

bg00 <- st_read(here("data/geopackage/nhgis_block_groups.gpkg"), layer = "US_block_groups_2000")

sel00 <- bg00%>%
  mutate(Area_00 = st_area(bg00)%>%
           set_units(km^2))%>%
  select(GISJOIN, Housing_Units, Area_00)
colnames(sel00) <- c("GISJOIN00","HU_00","Area_00","geom")

bg00_pts <- st_centroid(sel00)

# Join the two
join <- st_join(bg00_pts,sel90)%>%
  filter(!is.na(GISJOIN00) &
           !is.na(GISJOIN90))%>%
  mutate(Area_Chg_00 = (as.numeric(Area_00) - as.numeric(Area_90))/as.numeric(Area_90))%>%
  filter(abs(Area_Chg_00)<=.001)%>%
  filter(HU_90>0)%>%
  mutate(HU_Change00 = ((HU_00/as.numeric(Area_00)) - (HU_90/as.numeric(Area_90)))/(HU_90/as.numeric(Area_90)))

# test for normalcy
for(n in 1:20){
  samp <- sample_n(join, 500)
  p <- shapiro.test(samp$HU_Change00)
  print(paste0("Sample ",n,": ",p$p.value))
}


# map outliers
df90 <- bg90%>%
  st_drop_geometry()
library(leaflet)
filt1 <- join%>%
  filter(HU_Change00 > 10)%>%
  left_join(df90, by = c("GISJOIN90"="GISJOIN"))%>%
  st_transform(crs=4326)

leaflet(filt1)%>%
  addTiles()%>%
  addMarkers()

t1 <- sf%>%
  mutate(T1_Valid = ifelse(((hu_km2_00-hu_km2_90)/hu_km2_90)<10,TRUE,FALSE))%>%
  select(GISJOIN,T1_Valid)%>%
  st_drop_geometry()

# Test #2: (2)	Housing change from 2000 - 2010:  Realistic housing unit density change was 
# determined for block groups between 2000 and 2010 by identifying block groups which maintained 
# the exact same boundaries between census collection years and then finding the range of housing 
# unit density changes for these block groups. The boundary files for block groups in 2000 and 2010
# use the same spatial basis (2010 Tiger Line files), i.e. if they have not been redrawn, their 
# geometries are identical. It could therefore be determined if block groups were identical by 
# using the function 'st_equals_exactly' (sf package)


bg10 <- st_read(here("data/geopackage/nhgis_block_groups.gpkg"), layer = "US_block_groups_2010")

sel10 <- bg10%>%
  mutate(Area_10 = st_area(bg10)%>%
           set_units(km^2))%>%
  select(GISJOIN,Housing_Units, Area_10)
colnames(sel10) <- c("GISJOIN10","HU_10","Area_10","geom")


bg10_pts <- st_centroid(sel10)

join10 <- st_join(bg10_pts,sel00)%>%
  filter(!is.na(GISJOIN00) &
           !is.na(GISJOIN10))%>%
  filter(Area_10 == Area_00)%>%
  filter(HU_00>0)%>%
  mutate(HU_Change10 = ((HU_10/as.numeric(Area_10))-(HU_00/as.numeric(Area_00)))/(HU_00/as.numeric(Area_00)))

# test for normalcy
for(n in 1:20){
  samp <- sample_n(join10, 500)
  p <- shapiro.test(samp$HU_Change10)
  print(paste0("Sample ",n,": ",p$p.value))
}

filt2 <- join10%>%
  filter(HU_Change10 > 10)%>%
  left_join(df, by = c('GISJOIN10' = 'GISJOIN'))%>%
  st_transform(crs=4326)

# Map outliers
leaflet(filt2)%>%
  addTiles()%>%
  addMarkers()


t2 <- sf%>%
  mutate(T2_Valid = ifelse((((Housing_Units/Area)-hu_km2_00)/hu_km2_00)<10,TRUE,FALSE))%>%
  select(GISJOIN,T2_Valid)%>%
  st_drop_geometry()


# This section is a way to iterate through geometries to check for identical polygons, however
# it will take multiple days to complete so we use the above method instead.

#library(doParallel)
#registerDoParallel(100)

#start <- Sys.time()
#df <- data.frame()
#ident <- foreach(k = 1:1000,.combine=rbind,.packages=c("sf","tidyverse"))%dopar%{
#  row <- join10[k,]
#  id00 <- bg00%>%
#    filter(GISJOIN == row$GISJOIN00)
#  id10 <- bg10%>%
#    filter(GISJOIN == row$GISJOIN10)
#  equals <- st_equals(id00,id10,sparse = FALSE)
#  out <- data.frame("GISJOIN" = row$GISJOIN10, "Identical" = equals[1,1])
#  df <- rbind(df,out)
#}
#end <- Sys.time()
#end-start

# Test #3: (3)	Ratio of wells to housing units:  Results were determined to be unrealistic if there were 
# far more wells predicted in a block group than existing housing units. The predicted number of wells was 
# compared to the known number of housing units (2010 census) for each block group. If a block group had five 
# percent or more wells than it had housing units, the results for that block group were considered unrealistic.

t3 <- sf%>%
  filter(hybrd_2010 > 0)%>%
  mutate(T3_Valid = ifelse(hybrd_2010/(Housing_Units/as.numeric(Area))<= 1, TRUE, FALSE))%>%
  select(GISJOIN,T3_Valid)%>%
  st_drop_geometry()

# Test #4:

t4 <- sf%>%
  mutate(T4_Valid = ifelse(Housing_Units/as.numeric(Area)<1667,TRUE,FALSE))%>%
  select(GISJOIN,T4_Valid)%>%
  st_drop_geometry()


# Test #5: 

t5 <- sf%>%
  mutate(T5_Valid = ifelse(hybrd_2010<1667,TRUE,FALSE))%>%
  select(GISJOIN, T5_Valid)%>%
  st_drop_geometry()


sfQA <- sf%>%
  left_join(t1)%>%
  left_join(t2)%>%
  left_join(t3)%>%
  left_join(t4)%>%
  left_join(t5)%>%
  mutate(Wells = hybrd_2010/Area)

st_write(sfQA, here("data/geopackage/final_estimates.gpkg"), layer= "All_Estimates_Blk_Grps_QA", append = FALSE)


