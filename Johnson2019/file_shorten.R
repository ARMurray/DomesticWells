
files <- list.files(here("data/tables"))
files

for(n in 1:length(files)){
  file <- read.csv(here("data/tables",files[n]))
  newname <- substr(files[n],11,nchar(files[n]))
  write.csv(file, here("data/tables",newname))
}