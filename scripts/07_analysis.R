library(tidyverse)
library(sf)
library(ggplot2)
library(here)


# Import Geographic Data

# County and State names to join to the block group estimates
counties <- st_read(here("data/geopackage/nhgis_counties.gpkg"), layer= "2010_Counties")

countiesJoin <- counties%>%
  mutate(ST_CO = paste0(STATEFP,COUNTYFP))%>%
  select(ST_CO,STATE,COUNTY)%>%
  st_drop_geometry()

sf <- st_read(here("data/geopackage/final_estimates.gpkg"), layer= "All_Estimates_Blk_Grps_QA")%>%
  mutate(ST_CO = paste0(STATEFP10,COUNTYFP10))%>%
  left_join(countiesJoin, by = "ST_CO")

# Total Estimated Wells
sum(sf$Wells_HYBRD, na.rm = TRUE)

# Count the number of block groups with at least 1 flag
flagCount <- sf%>%
  filter(T1_Valid == FALSE |
           T2_Valid == FALSE |
           T3_Valid == FALSE |
           T4_Valid == FALSE |
           T5_Valid == FALSE)


# Count the flags by category
flag1 <- sf%>%
  filter(T1_Valid == FALSE)

flag2 <- sf%>%
  filter(T2_Valid == FALSE)

flag3 <- sf%>%
  filter(T3_Valid == FALSE)

flag4 <- sf%>%
  filter(T4_Valid == FALSE & Wells_HYBRD >= 1)

flag5 <- sf%>%
  filter(T5_Valid == FALSE)



# Bar Plot showing all block groups vs. only Valid
T1_2Valid <- sf%>%
  filter(T1_Valid == FALSE |
           T2_Valid == FALSE)

allvalid <- sf%>%
  filter(T1_Valid == TRUE &
           T2_Valid == TRUE &
           T3_Valid == TRUE &
           T4_Valid == TRUE &
           T5_Valid == TRUE)

sum(allvalid$Wells_HYBRD)



# RW filter
rw <- sf%>%
  filter(!is.na(RW_2010))

RWW <- rw%>%
  filter(Wells_HYBRD >= 1)

rwval <- RWW%>%
  filter(T1_Valid == TRUE&
           T2_Valid == TRUE &
           T3_Valid == TRUE &
           T4_Valid == TRUE &
           T5_Valid == TRUE)

# Estimate population served
sf$pop_per_HU <- ifelse(sf$Housing_Units>0, sf$Population/sf$Housing_Units,0)
sf$popServed <- sf$pop_per_HU*sf$Wells_HYBRD
sum(sf$popServed, na.rm = TRUE)

# Bar chart of block groups flagged vs not-flagged
ggplot()+
  geom_bar(data = sf, aes(x = STATEFP10, y = Wells_HYBRD), stat = "sum", fill = "#b4b8b5")+
  geom_bar(data = allvalid, aes(x = STATEFP10, y = Wells_HYBRD), stat = "sum", fill = '#35b858')+
  coord_flip()



# Export Block Groups for GeoPlatform Layer
sfOut <- sf%>%
  select(GISJOIN,STATE,COUNTY,Population,Housing_Units,hybrd_2010,Wells_HYBRD,popServed,T1_Valid,T2_Valid,T3_Valid,T4_Valid,T5_Valid)
