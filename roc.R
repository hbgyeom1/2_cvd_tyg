setwd("C:/Users/user/Documents/2_cvd_tyg")
library(data.table);library(haven);library(magrittr)
library(survey);library(pROC);library(ggplot2)

dd <- read_sas("C:/Users/user/Documents/2_cvd_tyg/data/out.sas7bdat") %>% setDT()
dd <- dd[complete.cases(dd)]
dd <- dd[subject != 0]

dat <- as.data.table(dd)
des <- svydesign(ids = ~psu, strata = ~kstrata, weights = ~wt_adj, data = dat, nest = T)

fit <- svyglm(hypertension_g ~ age_g + sex + town_t + educ_g + ho_incm +
                marri_g + health_g + stress_g + drinking_g + smoking_g +
                HE_ast + HE_alt + HE_HB + HE_BUN + HE_crea + HE_Uph,
              design = des, family = quasibinomial())

dat$pred <- predict(fit, type = "response")
roc_obj <- roc(dat$hypertension_g, dat$pred)
plot(roc_obj, print.auc = T)
