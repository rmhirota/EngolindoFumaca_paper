# join pm25

pm25 <- readr::read_rds("Data/tidy/municipios_pm25.rds")
municipios <- dplyr::distinct(
  pm25, code_muni, name_muni, code_state, abbrev_state
)

# Salva tabela de municípios para uso em outras bases
readr::write_rds(municipios, "Data/tidy/tbl_municipios.rds")

pm25 <- dplyr::filter(pm25, !is.na(ppm25), ppm25 != "NaN")

# tabela de semana epidemiologica
de_para_se <- readr::read_rds("Data/tidy/semana_epidemiologica.rds")

# médias por dia
pm25_media_muni <- pm25 |>
  dplyr::group_by(code_muni, name_muni, code_state, abbrev_state, date) |>
  dplyr::summarise(
    mean_ppm25 = mean(ppm25),
    median_ppm25 = median(ppm25),
    max_ppm25 = max(ppm25),
    acima_25 = ppm25 > 25,
    .groups = "drop"
  ) |>
  dplyr::mutate(
    code_muni = stringr::str_sub(code_muni, 1, 6),
    date = lubridate::ymd(date),
    mes = lubridate::month(date),
    ano = lubridate::year(date),
    ano_mes = paste0(ano, "_", stringr::str_pad(mes, 2, pad = 0)),
  ) |>
  dplyr::left_join(de_para_se, c("date" = "inicio"))

readr::write_rds(pm25_media_muni, "Data/tidy/municipios_pm25_medias_dia.rds")

# médias por semana epidemiológica

# dias acima da média recomendada por semana
acima_25_semana <- pm25_media_muni |>
  dplyr::group_by(code_muni, semana_epi, semana_epi_ano) |>
  dplyr::summarise(dias_acima_25 = sum(acima_25), .groups = "drop")

pm25_media_muni_semana <- pm25 |>
  dplyr::mutate(
    code_muni = stringr::str_sub(code_muni, 1, 6),
    date = lubridate::ymd(date),
    mes = lubridate::month(date),
    ano = lubridate::year(date),
    ano_mes = paste0(ano, "_", stringr::str_pad(mes, 2, pad = 0)),
  ) |>
  dplyr::left_join(de_para_se, c("date" = "inicio")) |>
  dplyr::group_by(code_muni, name_muni, code_state, abbrev_state, semana_epi, semana_epi_ano) |>
  dplyr::summarise(
    mean_ppm25 = mean(ppm25),
    median_ppm25 = median(ppm25),
    max_ppm25 = max(ppm25),
    .groups = "drop"
  ) |>
  dplyr::left_join(acima_25_semana, c("code_muni", "semana_epi", "semana_epi_ano"))

readr::write_rds(pm25_media_muni_semana, "Data/tidy/municipios_pm25_medias_semana.rds")
