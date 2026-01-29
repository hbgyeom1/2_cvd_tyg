setwd("C:/Users/user/Documents/2_cvd_tyg")
library(data.table);library(haven);library(magrittr)

dd <- read_sas("C:/Users/user/Documents/2_cvd_tyg/data/dd.sas7bdat") %>% setDT()
n_count <- colSums(is.na(dd));n_count

dd[, sum(is.na(age_g))];dd <- dd[!is.na(age_g)] #27026
dd[, sum(is.na(prg_g) | prg_g == 1, na.rm = TRUE)];dd <- dd[!(is.na(prg_g) | prg_g == 1)] #2450

dd <- dd[complete.cases(dd)]
fwrite(dd, "C:/Users/user/Documents/2_cvd_tyg/data/dd.csv")
