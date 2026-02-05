setwd("C:/Users/user/Documents/2_cvd_tyg/r")
library(data.table);library(haven);library(magrittr)
library(survey);library(splines);library(ggplot2)
library(patchwork);library(officer);library(rvg)
source("C:/Users/user/Documents/2_cvd_tyg/r/mkfig.R")

dd <- read_sas("C:/Users/user/Documents/2_cvd_tyg/data/dd.sas7bdat") %>% setDT()
dd <- dd[complete.cases(dd)]
dd <- dd[subject != 0]

dat <- as.data.table(dd)

dat$age_g <- factor(dat$age_g)
dat$sex <- factor(dat$sex)
dat$town_t <- factor(dat$town_t)
dat$educ_g <- factor(dat$educ_g)
dat$ho_incm <- factor(dat$ho_incm)
dat$marri_g <- factor(dat$marri_g)
dat$health_g <- factor(dat$health_g)
dat$stress_g <- factor(dat$stress_g)
dat$drinking_g <- factor(dat$drinking_g)
dat$smoking_g <- factor(dat$smoking_g)


des <- svydesign(ids = ~psu, strata = ~kstrata, weights = ~wt_adj, data = dat, nest = T)


p1 <- rcs_plot("hypertension_g", "tyg", "TyG")
p2 <- rcs_plot("hypertension_g", "tyg_absi", "TyG-ABSI")
p3 <- rcs_plot("hypertension_g", "aip", "AIP")
p4 <- rcs_plot("hypertension_g", "mets_ir", "METS-IR")

f2 <- p1 + p2 + p3 + p4 +
  plot_layout(axes = "collect", axis_titles = "collect"); f2

p1 <- rcs_plot("dyslipidemia_g", "tyg", "TyG")
p2 <- rcs_plot("dyslipidemia_g", "tyg_absi", "TyG-ABSI")
p3 <- rcs_plot("dyslipidemia_g", "aip", "AIP")
p4 <- rcs_plot("dyslipidemia_g", "mets_ir", "METS-IR")

f3 <- p1 + p2 + p3 + p4 +
  plot_layout(axes = "collect", axis_titles = "collect"); f3

p1 <- rcs_plot("stroke_g", "tyg", "TyG")
p2 <- rcs_plot("stroke_g", "tyg_absi", "TyG-ABSI")
p3 <- rcs_plot("stroke_g", "aip", "AIP")
p4 <- rcs_plot("stroke_g", "mets_ir", "METS-IR")

f4 <- p1 + p2 + p3 + p4 +
  plot_layout(axes = "collect", axis_titles = "collect"); f4

p1 <- rcs_plot("mi_g", "tyg", "TyG")
p2 <- rcs_plot("mi_g", "tyg_absi", "TyG-ABSI")
p3 <- rcs_plot("mi_g", "aip", "AIP")
p4 <- rcs_plot("mi_g", "mets_ir", "METS-IR")

f5 <- p1 + p2 + p3 + p4 +
  plot_layout(axes = "collect", axis_titles = "collect"); f5

p1 <- rcs_plot("angina_g", "tyg", "TyG")
p2 <- rcs_plot("angina_g", "tyg_absi", "TyG-ABSI")
p3 <- rcs_plot("angina_g", "aip", "AIP")
p4 <- rcs_plot("angina_g", "mets_ir", "METS-IR")

f6 <- p1 + p2 + p3 + p4 +
  plot_layout(axes = "collect", axis_titles = "collect"); f6

# plots <- list(f2, f3, f4, f5, f6)
# ppt <- read_pptx()
# for (p in plots) {
#   ppt <- ppt %>%
#     add_slide(layout = "Title and Content", master = "Office Theme") %>%
#     ph_with(
#       dml(ggobj = p),
#       location = ph_location_fullsize()
#     )
# }
# 
# print(ppt, target = "C:/Users/user/Documents/2_cvd_tyg/figure/figure2.pptx")