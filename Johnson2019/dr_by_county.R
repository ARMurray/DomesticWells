library(sf)
library(dplyr)
library(units)
library(ggplot2)
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
cnty80$area <- set_units(st_area(cnty80), km^2)
cnty90$area <- set_units(st_area(cnty90), km^2)

# Calculate Domestic Ratio (DR)
cnty70$dr <- cnty70$Well/cnty70$H_Units
cnty80$dr <- (cnty80$Drilled+cnty80$Dug)/cnty80$H_Units
cnty90$dr <- (cnty90$Drilled=cnty90$Dug)/cnty90$H_Units

# Calculate housing unit density
cnty70$hu_density <- cnty70$H_Units/cnty70$area
cnty80$hu_density <- cnty80$H_Units/cnty80$area
cnty90$hu_density <- cnty90$H_Units/cnty90$area

# Plots of wells vs housing unit density
ggplot()+
  geom_point(data = cnty70, aes(x=as.numeric(hu_density), y=dr),color='red')+
  geom_point(data = cnty80, aes(x=as.numeric(hu_density), y=dr),color='blue')+
  geom_point(data = cnty90, aes(x=as.numeric(hu_density), y=dr),color='green')+
  xlim(xmin=0,xmax=1000)


# Longitudinal plot
