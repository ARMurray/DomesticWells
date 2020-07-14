library(dplyr)
library(sf)
library(here)


bgr <- st_read(here("results/National Files.gdb"), layer = "US_Blk_Grps_2010")

layers <- st_layers(here("results/National Files.gdb"))
layers
