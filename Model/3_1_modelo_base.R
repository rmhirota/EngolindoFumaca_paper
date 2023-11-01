# dados poluição
pm25_semana <- readr::read_rds("Data/tidy/municipios_pm25_medias_semana.rds")

# dados sivpe
sivep <- readr::read_rds("Data/tidy/sivep.rds")
sivep_semana <- sivep |>
  dplyr::mutate(srag = TRUE) |>
  dplyr::group_by(co_mun_res, sg_uf, id_mn_resi, semana_epi, semana_epi_ano, mes_ano) |>
  dplyr::summarise(
    apenas_covid = sum(apenas_covid),
    covid_sintomas = sum(covid_sintomas),
    srag = sum(srag), .groups = "drop"
  )

# dados pnud
pnud <- readr::read_rds("Data/tidy/populacao.rds")
pop_uf <- readr::read_rds("Data/tidy/populacao_uf.rds")

# dados vacina
vac_semana <- readr::read_rds("Data/tidy/vacinacao_semanal.rds")

# dados precipitação
precip <- "Data/tidy/precip_long.rds" |>
  readr::read_rds() |>
  dplyr::select(-.geo) |>
  dplyr::mutate(co_mun_res = stringr::str_sub(code, 1, 6))

# de=para semana epidemiologica
semana <- readr::read_rds("Data/tidy/semana_epidemiologica.rds")

# cria base para modelo
base_modelo <- sivep_semana |>
  dplyr::mutate(co_mun_res = as.character(co_mun_res)) |>
  dplyr::left_join(
    pm25_semana, c("co_mun_res" = "code_muni", "semana_epi", "semana_epi_ano")
  ) |>
  dplyr::left_join(vac_semana, c("sg_uf" = "UF", "semana_epi", "semana_epi_ano")) |>
  tidyr::replace_na(list(
    `5-11 anos` = 0,
    `12-17 anos` = 0,
    `18-29 anos` = 0,
    `30-39 anos` = 0,
    `40-49 anos` = 0,
    `50-59 anos` = 0,
    `60-69 anos` = 0,
    `70-79 anos` = 0,
    `80-89 anos` = 0,
    `90+ anos` = 0
  )) |>
  dplyr::mutate(
    total_vacinadas =
      `5-11 anos` +
        `12-17 anos` +
        `18-29 anos` +
        `30-39 anos` +
        `40-49 anos` +
        `50-59 anos` +
        `60-69 anos` +
        `70-79 anos` +
        `80-89 anos` +
        `90+ anos`
  ) |>
  dplyr::filter(!is.na(week)) |>
  dplyr::left_join(pnud, c("co_mun_res" = "code_muni")) |>
  dplyr::left_join(pop_uf, c("sg_uf" = "uf")) |>
  dplyr::left_join(precip, c("co_mun_res", "mes_ano")) |>
  dplyr::mutate(pct_vacinada = total_vacinadas / pop_uf)


readr::write_rds(base_modelo, "Data/tidy/base_modelo.rds")
