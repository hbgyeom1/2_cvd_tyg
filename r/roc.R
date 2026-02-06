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

p1 <- roc_plot1("hypertension_g") +
  labs(y = "Sensitivity") + theme(axis.title.x = element_blank())
p2 <- roc_plot1("dyslipidemia_g") +
  labs(y = "Sensitivity") + theme(axis.title.x = element_blank())
p3 <- roc_plot1("stroke_g") +
  labs(y = "Sensitivity") + theme(axis.title.x = element_blank())
p4 <- roc_plot1("mi_g") +
  labs(y = "Sensitivity") + theme(axis.title.x = element_blank())
p5 <- roc_plot1("angina_g") +
  labs(y = "Sensitivity") + theme(axis.title.x = element_blank())


f12 <- p1 + p2 +
  plot_annotation(tag_levels = 'A') +
  plot_layout(axis_titles = "collect") &
  theme(plot.margin = margin(10, 10, 10, 10, unit = "pt"))

f34 <- p3 + p4 +
  plot_annotation(tag_levels = 'A') +
  plot_layout(axis_titles = "collect") &
  theme(plot.margin = margin(10, 10, 10, 10, unit = "pt"))

f55 <- p5 + p5 +
  plot_annotation(tag_levels = 'A') +
  plot_layout(axis_titles = "collect") &
  theme(plot.margin = margin(10, 10, 10, 10, unit = "pt"))


plots <- list(f55)
ppt <- read_pptx()
for (p in plots) {
  ppt <- ppt %>%
    add_slide(layout = "Title and Content", master = "Office Theme") %>%
    ph_with(
      dml(ggobj = p),
      location = ph_location(
        width = 10,
        height = 5,
        left = 1,
        top = 1
      )
    )
}

print(ppt, target = "C:/Users/user/Documents/2_cvd_tyg/figure/figure3.pptx")
