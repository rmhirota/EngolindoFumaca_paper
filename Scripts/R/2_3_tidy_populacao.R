capitais <- c(
  "120040", "160030", "130260", "510340", "150140",
  "110020", "140010", "172100", "211130"
)

pnud <- abjData::pnud_min |>
  dplyr::filter(ano == "2010") |>
  dplyr::mutate(muni_id = stringr::str_sub(muni_id, 1, 6)) |>
  dplyr::transmute(
    code_muni = muni_id,
    capital = ifelse(code_muni %in% capitais, TRUE, FALSE),
    muni_nm,
    uf = uf_sigla,
    idhm,
    espvida,
    rdpc,
    gini,
    pop,
    porte = as.factor(dplyr::case_when(
      pop < 25000 ~ "p",
      pop < 100000 ~ "m",
      TRUE ~ "g"
    ))
  )

readr::write_rds(pnud, "Data/tidy/populacao.rds")

pop_uf <- pnud |>
  dplyr::group_by(uf) |>
  dplyr::summarise(pop_uf = sum(pop))
readr::write_rds(pop_uf, "Data/tidy/populacao_uf.rds")
