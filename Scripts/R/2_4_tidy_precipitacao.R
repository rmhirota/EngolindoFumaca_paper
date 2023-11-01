precip <- readr::read_rds("Data/tidy/precipitation.rds")
dplyr::glimpse(precip)

# pedir dados agrupados por dia ou por semana
# período: 2017 a 2023

precip_tidy <- precip |>
  dplyr::select(-1) |>
  dplyr::relocate(UF, code, name, .geo) |>
  tidyr::pivot_longer(5:40, names_to = "mes_ano", values_to = "precipitacao")

readr::write_rds(precip_tidy, "Data/tidy/precip_long.rds")
