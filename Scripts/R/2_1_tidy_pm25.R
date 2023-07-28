# join pm25

pm25 <- readr::read_rds("Data/tidy/municipios_pm25.rds")
municipios <- dplyr::distinct(
  pm25, code_muni, name_muni, code_state, abbrev_state
)

# Salva tabela de municípios para uso em outras bases
readr::write_rds(municipios, "Data/tidy/tbl_municipios.rds")

dplyr::glimpse(pm25)

pm25 <- dplyr::filter(pm25, !is.na(ppm25), ppm25 != "NaN")

pm25_media_muni <- pm25 |>
  dplyr::group_by(code_muni, name_muni, code_state, abbrev_state, date) |>
  dplyr::summarise(
    mean_ppm25 = mean(ppm25),
    median_ppm25 = median(ppm25),
    max_ppm25 = max(ppm25),
    .groups = "drop"
  ) |>
  dplyr::mutate(
    code_muni = stringr::str_sub(code_muni, 1, 6),
    date = lubridate::ymd(date),
    mes = lubridate::month(date),
    ano = lubridate::year(date),
    ano_mes = paste0(ano, "_", stringr::str_pad(mes, 2, pad = 0))
  )

readr::write_rds(pm25_media_muni, "Data/tidy/municipios_pm25_medias_dia.rds")

