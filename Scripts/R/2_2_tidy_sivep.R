# tidy datasus

# datasus2023 <- readr::read_csv2("https://s3.sa-east-1.amazonaws.com/ckan.saude.gov.br/SRAG/2023/INFLUD23-12-06-2023.csv")
# datasus2022 <- readr::read_csv2("https://s3.sa-east-1.amazonaws.com/ckan.saude.gov.br/SRAG/2022/INFLUD22-03-04-2023.csv")
# datasus2021 <- readr::read_csv2("https://s3.sa-east-1.amazonaws.com/ckan.saude.gov.br/SRAG/2021/INFLUD21-01-05-2023.csv")

sivep <- readr::read_csv2("Data/raw/SRAGHospitalizado_2023_03_20_csv.xz")

# sanity checks
sivep |>
  dplyr::filter(!is.na(DT_INTERNA)) |>
  dplyr::mutate(ano = stringr::str_extract(DT_NOTIFIC, "[0-9]{4}$")) |>
  dplyr::count(ano)

tirar_var <- c(
  "co_ps_vgm", "cod_idade", "dt_rt_vgm", "dt_vgm",
  "obes_imc",  "pac_cocbo", "pac_dscbo", "pais_vgm"
)

# Municípios que serão usados
municipios <- readr::read_rds("Data/tidy/municipios.rds")
municipios <- municipios |>
  dplyr::select(-geom) |>
  tibble::as_tibble() |>
  dplyr::mutate(code_muni = stringr::str_sub(code_muni, 1, 6))

sivep <- sivep |>
  janitor::clean_names() |>
  dplyr::filter(
    co_mun_res %in% municipios$code_muni,  # municípios Amazônia
    !is.na(dt_interna)  # apenas casos com internação
  ) |>
  dplyr::select(-dplyr::all_of(tirar_var)) |>
  dplyr::mutate(
    dplyr::across(dplyr::starts_with("dt_"), lubridate::dmy),
    dt_exposicao = dt_interna - 7,
    indef = ifelse(classi_fin %in% 1:3, FALSE, TRUE),
    apenas_covid = ifelse(classi_fin != 5 | is.na(classi_fin), FALSE, TRUE),
    tosse = ifelse(tosse == 1 & !is.na(tosse), TRUE, FALSE),
    garganta = ifelse(garganta == 1 & !is.na(garganta), TRUE, FALSE),
    desc_resp = ifelse(desc_resp == 1 & !is.na(desc_resp), TRUE, FALSE),
    saturacao = ifelse(saturacao == 1 & !is.na(saturacao), TRUE, FALSE),
    perd_olft = ifelse(perd_olft == 1 & !is.na(perd_olft), TRUE, FALSE),
    perd_pala = ifelse(perd_pala == 1 & !is.na(perd_pala), TRUE, FALSE),
    sintomas = tosse + garganta + desc_resp + saturacao + perd_olft + perd_pala,
    febre = ifelse(febre != 1 | is.na(febre), FALSE, TRUE),
    covid_sintomas = apenas_covid | (indef & febre & sintomas > 0),
    covid_sintomas = covid_sintomas & (pos_pcrout != 2 | is.na(pos_pcrout)),
    obito = ifelse(evolucao == 2 & !is.na(evolucao), TRUE, FALSE),
    obito_covid = obito & apenas_covid
  ) |>
  tidyr::complete(
    code_muni, dt_exposicao = tidyr::full_seq(dt_exposicao, 1),
    fill = list(
      srag = 0, covid = 0, covid_indef = 0, covid_sintomas = 0,
      obito = 0, obito_covid = 0
    )
  )

readr::write_rds(sivep, "Data/tidy/sivep.rds")

sivep <- readr::read_rds("Data/tidy/sivep.rds")
dplyr::glimpse(sivep)





