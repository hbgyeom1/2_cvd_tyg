setwd("C:/Users/user/Documents/2_cvd_tyg/r")
library(data.table);library(haven);library(magrittr)
library(survey);library(pROC);library(ggplot2)
library(officer);library(patchwork);library(rvg)
source("C:/Users/user/Documents/2_cvd_tyg/r/mkfig.R")

dd <- read_sas("C:/Users/user/Documents/2_cvd_tyg/data/out.sas7bdat") %>% setDT()
dd <- dd[complete.cases(dd)]
dd <- dd[subject != 0]

dat <- as.data.table(dd)
des <- svydesign(ids = ~psu, strata = ~kstrata, weights = ~wt_adj, data = dat, nest = T)

# baseline + quartile
p1 <- roc_plot1("hypertension_g")
p2 <- roc_plot1("dyslipidemia_g")
p3 <- roc_plot1("stroke_g")
p4 <- roc_plot1("mi_g")
p5 <- roc_plot1("angina_g")

plots <- list(p1, p2, p3, p4, p5)
ppt <- read_pptx()
for (p in plots) {
  ppt <- ppt %>%
    add_slide(layout = "Title and Content", master = "Office Theme") %>%
    ph_with(
      dml(ggobj = p),
      location = ph_location_fullsize()
    )
}

print(ppt, target = "C:/Users/user/Documents/2_cvd_tyg/figure/figure3.pptx")

# baseline + numeric
p1 <- roc_plot2("hypertension_g")
p2 <- roc_plot2("dyslipidemia_g")
p3 <- roc_plot2("stroke_g")
p4 <- roc_plot2("mi_g")
p5 <- roc_plot2("angina_g")

plots <- list(p1, p2, p3, p4, p5)
ppt <- read_pptx()
for (p in plots) {
  ppt <- ppt %>%
    add_slide(layout = "Title and Content", master = "Office Theme") %>%
    ph_with(
      dml(ggobj = p),
      location = ph_location_fullsize()
    )
}

print(ppt, target = "C:/Users/user/Documents/2_cvd_tyg/figure/figure4.pptx")

# quartile
p1 <- roc_plot3("hypertension_g")
p2 <- roc_plot3("dyslipidemia_g")
p3 <- roc_plot3("stroke_g")
p4 <- roc_plot3("mi_g")
p5 <- roc_plot3("angina_g")

plots <- list(p1, p2, p3, p4, p5)
ppt <- read_pptx()
for (p in plots) {
  ppt <- ppt %>%
    add_slide(layout = "Title and Content", master = "Office Theme") %>%
    ph_with(
      dml(ggobj = p),
      location = ph_location_fullsize()
    )
}

print(ppt, target = "C:/Users/user/Documents/2_cvd_tyg/figure/figure5.pptx")

# numeric
p1 <- roc_plot4("hypertension_g")
p2 <- roc_plot4("dyslipidemia_g")
p3 <- roc_plot4("stroke_g")
p4 <- roc_plot4("mi_g")
p5 <- roc_plot4("angina_g")

plots <- list(p1, p2, p3, p4, p5)
ppt <- read_pptx()
for (p in plots) {
  ppt <- ppt %>%
    add_slide(layout = "Title and Content", master = "Office Theme") %>%
    ph_with(
      dml(ggobj = p),
      location = ph_location_fullsize()
    )
}

print(ppt, target = "C:/Users/user/Documents/2_cvd_tyg/figure/figure6.pptx")
