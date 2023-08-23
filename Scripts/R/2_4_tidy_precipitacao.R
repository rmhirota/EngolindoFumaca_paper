precip <- readr::read_rds("Data/tidy/precipitation.rds")
dplyr::glimpse(precip)

# pedir dados agrupados por dia ou por semana
# período: 2017 a 2023