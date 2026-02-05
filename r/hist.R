setwd("C:/Users/user/Documents/2_cvd_tyg/r")
library(data.table);library(haven);library(magrittr)
library(ggplot2);library(patchwork);library(officer);library(rvg)
source("C:/Users/user/Documents/2_cvd_tyg/r/mkfig.R")

dd <- read_sas("C:/Users/user/Documents/2_cvd_tyg/data/dd.sas7bdat") %>% setDT()
dd <- dd[complete.cases(dd)]
dd <- dd[subject != 0]


p1 <- hist_plot("tyg", "TyG")
p2 <- hist_plot("tyg_absi", "TyG-ABSI")
p3 <- hist_plot("aip", "AIP")
p4 <- hist_plot("mets_ir", "METS-IR")

f1 <- p1 + p2 + p3 + p4 +
  plot_layout(axes = "collect", axis_titles = "collect")

read_pptx() %>%
  add_slide(layout = "Title and Content", master = "Office Theme") %>%
  ph_with(
    dml(ggobj = f1),
    location = ph_location_fullsize()
  ) %>%
  print(target = "C:/Users/user/Documents/2_cvd_tyg/figure/figure1.pptx")
