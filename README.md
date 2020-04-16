# Estimating Domestic Wells for the United States in 2010

Below, you will find a step by step walkthrough of how to reproduce the estimates for private well locations in the United States using methods first proposed in [Weaver et al., 2017](https://www.sciencedirect.com/science/article/pii/S0048969717315280) and expanded upon in Murray et al., 2020 (in review). All of the scripts referenced below can be located in the DomesticWells/scripts/ folder.

## Data to download:

I recommend downloading all data from the [National Historical Geographic Information System](NHGIS.org).  They have added in easy to use join features for Census data which will avoid some headaches throughout the method.

GIS Boundary Shapefiles:
1.	1990 Census Block Groups
2.	2000 Census Block Groups (2010 Edition)
3.	2010 Census Block Groups
4.	2010 Census Water Area

Data Tables:
- 1990 Census
  - Source of Water
  - Housing Units
- 2000 Census
  - Housing Units
- 2010 Census
  - Housing Units
  - Total Population


## Software:

  You will need a recent distribution of R and R Studio. The packages you will need to install are listed here:
  
  -dplyr
  -sf
  -tidyr
  
## Data Preparation

| spatial data is delivered in shapefile format from NHGIS and while it is still the most widely use spatial file format, it is not particularly fast. For this reason, we want to convert the format to something more compact that will load and process faster. For this, we will use the [geopackage format](https://www.gis-blog.com/geopackage-vs-shapefile/).


