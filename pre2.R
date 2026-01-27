setwd("C:/Users/user/Documents/2_cvd_tyg")
library(data.table);library(haven);library(magrittr);library(CVrisk)

dd <- read_sas("C:/Users/user/Documents/2_cvd_tyg/data/dd.sas7bdat") %>% setDT()
dd[, sex_g := fifelse(sex == 1, "male", "female")]

prg1 <- dd[prg_g == 1, .N] # 453
dd[prg_g == 1, prg_g := NA]
n_count <- colSums(is.na(dd))
dd <- dd[complete.cases(dd)]

dd[, frs := ascvd_10y_frs(
  gender = sex_g,
  age = age,
  hdl = HE_HDL_st2,
  totchol = HE_chol,
  sbp = HE_sbp,
  bp_med = drug_g,
  smoker = smoking_g,
  diabetes = diabetes_g
)]

dd[, c("age", "prg_g", "HE_sbp", "HE_chol",
       "HE_HDL_st2", "drug_g", "diabetes_g", "sex_g") := NULL]

fwrite(dd, "C:/Users/user/Documents/2_cvd_tyg/data/dd.csv")