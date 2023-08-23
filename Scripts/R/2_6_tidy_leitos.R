leitos <- readr::read_csv2(
  "Data/raw/leitos.csv", skip = 4, locale = readr::locale(encoding = "latin1")
)
leitos <- leitos |>
  janitor::clean_names() |>
  dplyr::group_by(municipio) |>
  tidyr::pivot_longer(cols = 2:80) |>
  dplyr::ungroup() |>
  dplyr::mutate(value = ifelse(value == "-", 0, as.integer(value))) |>
  dplyr::filter(!is.na(value)) |>
  dplyr::mutate(
    name = stringr::str_remove(name, "^x")
  ) |>
  tidyr::separate(name, c("ano", "mes"), "_")


leitos |>
  dplyr::filter(
    !stringr::str_detect(municipio, "MUNICIPIO IGNORADO"),
    municipio != "Total"
  ) |>
  tidyr::separate(municipio, c("cod_municipio", "nome_municipio"))


dplyr::glimpse(leitos)
