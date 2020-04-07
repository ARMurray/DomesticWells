library(sf)
library(dplyr)
library(units)
library(here)

# Import Source of Water Data Tables
sow70 <- read.csv(here("data/tables/ds97_1970_county.csv"))%>%
  select(GISJOIN,CQK001,CQK002,CQK003)
colnames(sow70) <- c("GISJOIN","Public","Well","Other")

sow80 <- read.csv(here("data/tables/ds107_1980_county.csv"))%>%
  select(GISJOIN,DEO001,DEO002,DEO003,DEO004)
colnames(sow80) <- c("GISJOIN","Public","Drilled","Dug","Other")

sow90 <- read.csv(here("data/tables/ds123_1990_county.csv"))%>%
  select(GISJOIN,EX5001,EX5002,EX5003,EX5004)
colnames(sow90) <- c("GISJOIN","Public","Drilled","Dug","Other")

# Import Population & Housing Unit Tables
ph70 <- read.csv(here("data/tables/ds94_1970_county.csv"))%>%
  select(GISJOIN,CBC001,CBV001)
colnames(ph70) <- c("GISJOIN","Population","H_Units")

ph80 <- read.csv(here("data/tables/ds104_1980_county.csv"))%>%
  select(GISJOIN,C7L001,C8Y001)
colnames(ph80) <- c("GISJOIN","Population","H_Units")
  
ph90 <- read.csv(here("data/tables/ds120_1990_county.csv"))%>%
  select(GISJOIN,ET1001,ESA001)
colnames(ph90) <- c("GISJOIN","Population","H_Units")


# Import US County Shapefiles as sf objects and join table data
cnty70 <- st_read(here('data/shapefiles/US_county_1970.shp'))%>%
  left_join(sow70, by = 'GISJOIN')%>%
  left_join(ph70, by = 'GISJOIN')

cnty80 <- st_read(here('data/shapefiles/US_county_1980.shp'))%>%
  left_join(sow80, by = 'GISJOIN')%>%
  left_join(ph80, by = 'GISJOIN')

cnty90 <- st_read(here('data/shapefiles/US_county_1990.shp'))%>%
  left_join(sow90, by = 'GISJOIN')%>%
  left_join(ph90, by = 'GISJOIN')


# Calculate county areas
cnty70$area <- set_units(st_area(cnty70), km^2)
