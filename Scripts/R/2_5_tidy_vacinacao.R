# Dados mensais

vac_mes <- readr::read_csv("https://raw.githubusercontent.com/covid19br/dados-vacinas/main/doses_cobertura_proporcao_mes.csv")
dplyr::glimpse(vac_mes)

cod_idade <- tibble::tribble(
  ~codigo, ~ag_10, ~ag_child,
  1, "0-9 anos", "0-4 anos",
  2, "10-19 anos", "5-11 anos",
  3, "20-29 anos", "12-17 anos",
  4, "30-39 anos", "18-29 anos",
  5, "40-49 anos", "30-39 anos",
  6, "50-59 anos", "40-49 anos",
  7, "60-69 anos", "50-59 anos",
  8, "70-79 anos", "60-69 anos",
  9, "80-89 anos", "70-79 anos",
  10, "90+ anos", "80-89 anos",
  11, NA, "90+ anos",
)

vac_mes <- vac_mes |>
  dplyr::filter(dose %in% c("D1cum", "D2cum", "Rcum", "Dcum")) |>
  dplyr::group_by(month, agegroup, UF) |>
  dplyr::summarise(vacinados = sum(n), .groups = "drop") |>
  dplyr::inner_join(cod_idade, c("agegroup" = "codigo")) |>
  dplyr::select(-ag_10, -agegroup) |>
  tidyr::pivot_wider(names_from = ag_child, values_from = vacinados)

readr::write_rds(vac_mes, "Data/tidy/vacinacao_mensal.rds")


# Dados semanais

# tabela de semana epidemiologica
de_para_se <- readr::read_rds("Data/tidy/semana_epidemiologica.rds")

vac_semana <- readr::read_csv("https://raw.githubusercontent.com/covid19br/dados-vacinas/main/doses_cobertura_proporcao_semana.csv")
dplyr::glimpse(vac_semana)

vac_semana <- vac_semana |>
  dplyr::filter(dose %in% c("D1cum", "D2cum", "Rcum", "Dcum")) |>
  dplyr::group_by(week, agegroup, UF) |>
  dplyr::summarise(vacinados = sum(n), .groups = "drop") |>
  dplyr::inner_join(cod_idade, c("agegroup" = "codigo")) |>
  dplyr::select(-ag_10, -agegroup) |>
  tidyr::pivot_wider(names_from = ag_child, values_from = vacinados) |>
  dplyr::left_join(de_para_se, c("week" = "inicio"))

readr::write_rds(vac_semana, "Data/tidy/vacinacao_semanal.rds")


# dados por municípios
"https://github.com/covid19br/dados-vacinas/tree/main/municipios"