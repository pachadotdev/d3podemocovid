library(readr)
library(dplyr)
library(jsonlite)
library(d3po)

library(canadamaps)
library(rmapshaper)
library(geojsonio)

url <- "https://health-infobase.canada.ca/src/data/covidLive/vaccination-coverage-map.csv"
csv <- paste0("dev/", gsub(".*/", "", url))
if (!file.exists(csv)) download.file(url, csv)

vaccination_coverage <- read_csv(csv)

provinces <- get_provinces() %>%
  st_as_sf() %>%
  ms_simplify(keep = 0.1)

topojson_write(provinces, file = "dev/provinces.topojson", object_name = "default")

provinces <- fromJSON("dev/provinces.topojson", simplifyVector = F)

# we need to pass an ID to d3po or it won't work!
for (i in seq_along(provinces$objects$default$geometries)) {
  id <- provinces$objects$default$geometries[[i]]$properties$prname
  id <- gsub(" /.*", "", id)
  print(id)
  if (!is.null(id)) {
    provinces$objects$default$geometries[[i]]$id <- id
    provinces$objects$default$geometries[[i]]$properties <- NULL
  }
}

write_json(provinces, "dev/provinces.topojson", pretty = F, auto_unbox = T)

provinces <- fromJSON("dev/provinces.topojson", simplifyVector = F)

use_data(vaccination_coverage, overwrite = T)

use_data(provinces, overwrite = T)

vaccination_coverage <- vaccination_coverage %>%
  filter(week_end == as.Date("2023-04-23"), pruid != 1) %>%
  select(id = prename, proptotal_atleast1dose)

d3po(vaccination_coverage) %>%
  po_geomap(daes(group = id, color = proptotal_atleast1dose), map = provinces) %>%
  po_title("Cumulative percent of the population who have received at least 1 dose of a COVID-19 vaccine")
