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
  mutate(Area_Chg_00 = (as.numeric(Area_00) - as.numeric(Area_90))/as.numeric(Area_90))%>%
  filter(abs(Area_Chg_00)<=.001)%>%
  filter(HU_90>0)%>%
  mutate(HU_Change00 = ((HU_00/as.numeric(Area_00)) - (HU_90/as.numeric(Area_90)))/(HU_90/as.numeric(Area_90)))

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

ident <- st_equals_exact(sel00,sel10, par = 0)

# Pop per household
d <- st_read(here("data/geopackage/final_estimates.gpkg"))%>%
  filter(Housing_Units > 0)
#head(d)
d$pPerhu <- d$Population/d$Housing_Units
