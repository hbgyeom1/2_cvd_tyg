setwd("C:/Users/user/Documents/2_cvd_tyg")
library(data.table);library(haven);library(magrittr)
library(survey);library(pROC);library(ggplot2)
library(officer);library(rvg)

dd <- read_sas("C:/Users/user/Documents/2_cvd_tyg/data/out.sas7bdat") %>% setDT()
dd <- dd[complete.cases(dd)]
dd <- dd[subject != 0]

dat <- as.data.table(dd)
des <- svydesign(ids = ~psu, strata = ~kstrata, weights = ~wt_adj, data = dat, nest = T)

roc_plot <- function(y) {
  rocs <- lapply((c(NA, "tyg_g", "tyg_absi_g", "aip_g", "mets_ir_g")), function(x) {
    flm <- as.formula(paste0(
      y, " ~ ", if (is.na(x)) "" else paste0(x, " + "),
      " + age_g + sex + town_t + educ_g + ho_incm +
      marri_g + health_g + stress_g + drinking_g + smoking_g +
      HE_ast + HE_alt + HE_HB + HE_BUN + HE_crea + HE_Uph"))
    fit <- svyglm(flm, design = des, family = quasibinomial())
    pred <- predict(fit, type = "response")
    roc(dat[[y]], pred, quiet = T)
  }) %>% setNames(c("Basic model", "+ TyG", "+ TyG-ABSI", "+ AIP", "+ METS-IR"))
  auc_vals <- sapply(rocs, auc)
  print(auc_vals)
  ggroc(rocs, legacy.axes = T) +
    geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
    scale_x_continuous(expand = c(0, 0)) +
    scale_y_continuous(expand = c(0, 0)) +
    labs(x = "1 - specificity", y = "Sensitivity") +
    theme(
      legend.title = element_blank(),
      legend.position = c(0.85, 0.20),
      axis.line = element_blank(),
      panel.border = element_rect(fill = NA, linewidth = 0.6),
      panel.background = element_rect(fill = "white"),
      plot.background  = element_rect(fill = "white"),
      text = element_text(size = 14, family = "Times New Roman")
    )
}

p1 <- roc_plot("hypertension_g")
p2 <- roc_plot("dyslipidemia_g")
p3 <- roc_plot("stroke_g")
p4 <- roc_plot("mi_g")
p5 <- roc_plot("angina_g")

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

print(ppt, target = "figure/figure3.pptx")