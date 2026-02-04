setwd("C:/Users/user/Documents/2_cvd_tyg")
library(data.table);library(haven);library(magrittr)
library(survey);library(pROC);library(ggplot2)

dd <- read_sas("C:/Users/user/Documents/2_cvd_tyg/data/out.sas7bdat") %>% setDT()
dd <- dd[complete.cases(dd)]
dd <- dd[subject != 0]

dat <- as.data.table(dd)
des <- svydesign(ids = ~psu, strata = ~kstrata, weights = ~wt_adj, data = dat, nest = T)

# fit <- svyglm(hypertension_g ~ age_g + sex + town_t + educ_g + ho_incm +
#                 marri_g + health_g + stress_g + drinking_g + smoking_g +
#                 HE_ast + HE_alt + HE_HB + HE_BUN + HE_crea + HE_Uph,
#               design = des, family = quasibinomial())
# 
# dat$pred <- predict(fit, type = "response")
# roc_obj <- roc(dat$hypertension_g, dat$pred)
# p1 <- plot(roc_obj, print.auc = T) # 0.8231

roc_plot <- function(y, x) {
  flm <- as.formula(paste0(y, " ~ ", x, " + age_g + sex + town_t + educ_g + ho_incm +
                           marri_g + health_g + stress_g + drinking_g + smoking_g +
                           HE_ast + HE_alt + HE_HB + HE_BUN + HE_crea + HE_Uph"))
  fit <- svyglm(flm, design = des, family = quasibinomial())
  pred <- predict(fit, type = "response")
  roc_obj <- roc(dat[[y]], pred)
  plot(roc_obj, print.auc = TRUE)
}

p1 <- roc_plot("hypertension_g", "tyg_g"); p1
p2 <- roc_plot("hypertension_g", "tyg_absi_g"); p2
p3 <- roc_plot("hypertension_g", "aip_g"); p3
p4 <- roc_plot("hypertension_g", "mets_ir_g"); p4

p1 <- roc_plot("dyslipidemia_g", "tyg_g"); p1
p2 <- roc_plot("dyslipidemia_g", "tyg_absi_g"); p2
p3 <- roc_plot("dyslipidemia_g", "aip_g"); p3
p4 <- roc_plot("dyslipidemia_g", "mets_ir_g"); p4