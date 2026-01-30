setwd("C:/Users/user/Documents/2_cvd_tyg")
library(data.table);library(haven);library(magrittr)

dd <- read_sas("C:/Users/user/Documents/2_cvd_tyg/data/dd.sas7bdat") %>% setDT()
n_count <- colSums(is.na(dd));n_count
dd <- dd[complete.cases(dd)]
fwrite(dd, "C:/Users/user/Documents/2_cvd_tyg/data/dd.csv")
