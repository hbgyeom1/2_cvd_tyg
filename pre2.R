setwd("C:/Users/user/Documents/2_cvd_tyg")
library(data.table);library(haven);library(magrittr);library(CVrisk)

dd <- read_sas("C:/Users/user/Documents/2_cvd_tyg/data/dd.sas7bdat") %>% setDT()

na_age <- dd[, sum(is.na(age_g))]
dd <- dd[!is.na(age_g)]
na_prg <- dd[, sum(is.na(prg_g))]
dd <- dd[!is.na(prg_g)]
prg_n <- dd[, sum(prg_g == 1)]
dd <- dd[prg_g != 1]

na_count <- colSums(is.na(dd));na_count
dd <- dd[complete.cases(dd)]

dd[, sex_g := fifelse(sex == 1, "male", "female")]
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

fwrite(dd, "C:/Users/user/Documents/2_cvd_tyg/data/dd.csv")
