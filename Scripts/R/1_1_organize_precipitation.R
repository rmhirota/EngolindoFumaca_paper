library(tidyverse)

# 2020 ----
prec_2020 <- read_csv("../../Data/Raw/PrecipitacaoMediaMensal_2020.csv") %>% as_tibble()

(prec_2020 <- prec_2020 %>% dplyr::rename(
  jan_2020 = '0_precipitation',
  fev_2020 = '1_precipitation',
  mar_2020 = '2_precipitation',
  abr_2020 = '3_precipitation',
  mai_2020 = '4_precipitation',
  jun_2020 = '5_precipitation',
  jul_2020 = '6_precipitation',
  ago_2020 = '7_precipitation',
  set_2020 = '8_precipitation',
  out_2020 = '9_precipitation',
  nov_2020 = '10_precipitation',
  dez_2020 = '11_precipitation',
)
)

write_csv(prec_2020,
          "../../Data/Raw/PrecipitacaoMediaMensal_2020_mod.csv")
# 2021 ----
prec_2021 <- read_csv("../../Data/Raw/PrecipitacaoMediaMensal_2021.csv") %>% as_tibble()

(prec_2021 <- prec_2021 %>% dplyr::rename(
  jan_2021 = '0_precipitation',
  fev_2021 = '1_precipitation',
  mar_2021 = '2_precipitation',
  abr_2021 = '3_precipitation',
  mai_2021 = '4_precipitation',
  jun_2021 = '5_precipitation',
  jul_2021 = '6_precipitation',
  ago_2021 = '7_precipitation',
  set_2021 = '8_precipitation',
  out_2021 = '9_precipitation',
  nov_2021 = '10_precipitation',
  dez_2021 = '11_precipitation',
)
)

write_csv(prec_2021,
          "../../Data/Raw/PrecipitacaoMediaMensal_2021_mod.csv")

# 2022 ----
prec_2022 <- read_csv("../../Data/Raw/PrecipitacaoMediaMensal_2022.csv") %>% as_tibble()

(prec_2022 <- prec_2022 %>% dplyr::rename(
  jan_2022 = '0_precipitation',
  fev_2022 = '1_precipitation',
  mar_2022 = '2_precipitation',
  abr_2022 = '3_precipitation',
  mai_2022 = '4_precipitation',
  jun_2022 = '5_precipitation',
  jul_2022 = '6_precipitation',
  ago_2022 = '7_precipitation',
  set_2022 = '8_precipitation',
  out_2022 = '9_precipitation',
  nov_2022 = '10_precipitation',
  dez_2022 = '11_precipitation',
)
)

write_csv(prec_2022,
          "../../Data/Raw/PrecipitacaoMediaMensal_2022_mod.csv")


# organize as RDS
prec_csv <- list.files("../../Data/Raw",
           pattern = '_mod.csv',
           full.names = TRUE) %>% 
  lapply(read_csv) %>% 
  bind_rows
colnames(prec_csv)
saveRDS(prec_csv, "../../Data/tidy/precipitation.rds",
        compress = TRUE)
