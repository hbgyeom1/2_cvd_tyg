hist_plot <- function(x, t) {
  ggplot(dd, aes(x = .data[[x]])) +
    geom_histogram(
      bins = 30,
      fill = "#fe8019",
      color = "black"
    ) +
    geom_vline(
      xintercept = median(dd[[x]], na.rm = TRUE),
      linetype = "dashed",
      color = "red"
    ) +
    scale_x_continuous(expand = c(0, 0)) +
    scale_y_continuous(limits = c(0, 12000),
                       expand = c(0, 0),
                       breaks = seq(0, 12000, by = 3000)
    ) +
    labs(x = t, y = "Frequency") +
    theme(
      axis.line = element_blank(),
      panel.border = element_rect(color = "black", fill = NA, linewidth = 0.6),
      panel.background = element_rect(fill = "white", color = NA),
      plot.background  = element_rect(fill = "white", color = NA),
      text = element_text(size = 14, family = "Times New Roman"),
      # aspect.ratio = 1
    )
}


rcs_plot <- function(y, x, xlab) {
  kn <- svyquantile(as.formula(paste0("~", x)), des, quantiles = c(0.05, 0.35, 0.65, 0.95)) %>% 
    coef() %>% unname()
  fml <- substitute(
    yvar ~ ns(xvar, knots = k, Boundary.knots = b) + age_g + sex + town_t +
      educ_g + ho_incm + marri_g + health_g + stress_g + drinking_g + smoking_g +
      HE_ast + HE_alt + HE_HB + HE_BUN + HE_crea + HE_Uph,
    list(yvar = as.name(y), xvar = as.name(x), k = kn[2:3], b = kn[c(1,4)])
  )
  fit <- svyglm(fml, design = des, family = quasibinomial())
  qt <- svyquantile(as.formula(paste0("~", x)), des, quantiles = c(0.01, 0.99)) %>% 
    coef() %>% unname()
  xgrid <- seq(qt[1], qt[2], length.out = 300)
  xref <- svyquantile(as.formula(paste0("~", x)), des, quantiles = 0.5) %>% 
    coef() %>% unname()
  newdat <- data.frame(
    tmpx = xgrid,
    age_g = factor('2', levels = levels(dat$age_g)),
    sex = factor('1', levels = levels(dat$sex)),
    town_t = factor('1', levels = levels(dat$town_t)),
    educ_g = factor('4', levels = levels(dat$educ_g)),
    ho_incm = factor('4', levels = levels(dat$ho_incm)),
    marri_g = factor('1', levels = levels(dat$marri_g)),
    health_g = factor('2', levels = levels(dat$health_g)),
    stress_g = factor('2', levels = levels(dat$stress_g)),
    drinking_g = factor('2', levels = levels(dat$drinking_g)),
    smoking_g = factor('0', levels = levels(dat$smoking_g)),
    HE_ast = svyquantile(~HE_ast, des, 0.5) %>% coef() %>% unname(),
    HE_alt = svyquantile(~HE_alt, des, 0.5) %>% coef() %>% unname(),
    HE_HB = svyquantile(~HE_HB, des, 0.5) %>% coef() %>% unname(),
    HE_BUN = svyquantile(~HE_BUN, des, 0.5) %>% coef() %>% unname(),
    HE_crea = svyquantile(~HE_crea, des, 0.5) %>% coef() %>% unname(),
    HE_Uph = svyquantile(~HE_Uph, des, 0.5) %>% coef() %>% unname()
  )
  names(newdat)[names(newdat) == "tmpx"] <- x
  newref <- newdat
  newref[[x]] <- xref
  
  # preddat <- predict(fit, newdata = newdat, type = "link", se.fit = T)
  # predref <- predict(fit, newdata = newref, type = "link", se.fit = T)
  # logOR <- coef(preddat) - coef(predref)
  # se <- sqrt(SE(preddat) ^ 2 + SE(predref) ^ 2)
  # OR <- exp(logOR)
  # lwr <- exp(logOR - 1.96 * se)
  # upr <- exp(logOR + 1.96 * se)
  
  b <- coef(fit)
  V <- vcov(fit)
  X  <- model.matrix(delete.response(terms(fit)), newdat)
  X0 <- model.matrix(delete.response(terms(fit)), newref)
  D <- X - X0
  logOR <- drop(D %*% b)
  se <- sqrt(rowSums((D %*% V) * D))
  OR  <- exp(logOR)
  lwr <- exp(logOR - 1.96 * se)
  upr <- exp(logOR + 1.96 * se)
  ggplot() +
    geom_ribbon(aes(x = xgrid, ymin = lwr, ymax = upr), fill = "#83a598", alpha = 0.2) +
    geom_line(aes(x = xgrid, y = OR), linewidth = 1, color = "#83a598") +
    geom_hline(yintercept = 1, linetype = "dashed") +
    scale_x_continuous(expand = c(0, 0)) +
    scale_y_continuous(expand = c(0, 0)) +
    labs(x = xlab, y = "Weighted Odds Ratio") +
    coord_fixed() +
    theme(
      axis.line = element_blank(),
      panel.border = element_rect(fill = NA, linewidth = 0.6),
      panel.background = element_rect(fill = "white"),
      plot.background  = element_rect(fill = "white"),
      text = element_text(size = 14, family = "Times New Roman")
    )
}


roc_plot1 <- function(y) {
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
  # print(auc_vals)
  new_names <- sprintf("%s (AUC = %.3f)", names(rocs), as.numeric(auc_vals))
  rocs <- setNames(rocs, new_names)
  ggroc(rocs, legacy.axes = T) +
    geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
    scale_x_continuous(expand = c(0, 0)) +
    scale_y_continuous(expand = c(0, 0)) +
    labs(x = "1 - specificity", y = "Sensitivity") +
    coord_fixed() +
    theme(
      legend.title = element_blank(),
      legend.text = element_text(size = 12),
      legend.position = c(0.8, 0.20),
      axis.line = element_blank(),
      panel.border = element_rect(fill = NA, linewidth = 0.6),
      panel.background = element_rect(fill = "white"),
      plot.background  = element_rect(fill = "white"),
      text = element_text(size = 14, family = "Times New Roman")
    )
}


roc_plot2 <- function(y) {
  rocs <- lapply((c(NA, "tyg", "tyg_absi", "aip", "mets_ir")), function(x) {
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
  # print(auc_vals)
  new_names <- sprintf("%s (AUC = %.3f)", names(rocs), as.numeric(auc_vals))
  rocs <- setNames(rocs, new_names)
  ggroc(rocs, legacy.axes = T) +
    geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
    scale_x_continuous(expand = c(0, 0)) +
    scale_y_continuous(expand = c(0, 0)) +
    labs(x = "1 - specificity", y = "Sensitivity") +
    coord_fixed() +
    theme(
      legend.title = element_blank(),
      legend.text = element_text(size = 12),
      legend.position = c(0.8, 0.20),
      axis.line = element_blank(),
      panel.border = element_rect(fill = NA, linewidth = 0.6),
      panel.background = element_rect(fill = "white"),
      plot.background  = element_rect(fill = "white"),
      text = element_text(size = 14, family = "Times New Roman")
    )
}



roc_plot3 <- function(y) {
  rocs <- lapply((c("tyg_g", "tyg_absi_g", "aip_g", "mets_ir_g")), function(x) {
    flm <- as.formula(paste0(
      y, " ~ ", x))
    fit <- svyglm(flm, design = des, family = quasibinomial())
    pred <- predict(fit, type = "response")
    roc(dat[[y]], pred, quiet = T)
  }) %>% setNames(c("TyG", "TyG-ABSI", "AIP", "METS-IR"))
  auc_vals <- sapply(rocs, auc)
  # print(auc_vals)
  new_names <- sprintf("%s (AUC = %.3f)", names(rocs), as.numeric(auc_vals))
  rocs <- setNames(rocs, new_names)
  ggroc(rocs, legacy.axes = T) +
    geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
    scale_x_continuous(expand = c(0, 0)) +
    scale_y_continuous(expand = c(0, 0)) +
    labs(x = "1 - specificity", y = "Sensitivity") +
    coord_fixed() +
    theme(
      legend.title = element_blank(),
      legend.text = element_text(size = 12),
      legend.position = c(0.8, 0.20),
      axis.line = element_blank(),
      panel.border = element_rect(fill = NA, linewidth = 0.6),
      panel.background = element_rect(fill = "white"),
      plot.background  = element_rect(fill = "white"),
      text = element_text(size = 14, family = "Times New Roman")
    )
}


roc_plot4 <- function(y) {
  rocs <- lapply((c("tyg", "tyg_absi", "aip", "mets_ir")), function(x) {
    flm <- as.formula(paste0(
      y, " ~ ", x))
    fit <- svyglm(flm, design = des, family = quasibinomial())
    pred <- predict(fit, type = "response")
    roc(dat[[y]], pred, quiet = T)
  }) %>% setNames(c("TyG", "TyG-ABSI", "AIP", "METS-IR"))
  auc_vals <- sapply(rocs, auc)
  # print(auc_vals)
  new_names <- sprintf("%s (AUC = %.3f)", names(rocs), as.numeric(auc_vals))
  rocs <- setNames(rocs, new_names)
  ggroc(rocs, legacy.axes = T) +
    geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
    scale_x_continuous(expand = c(0, 0)) +
    scale_y_continuous(expand = c(0, 0)) +
    labs(x = "1 - specificity", y = "Sensitivity") +
    coord_fixed() +
    theme(
      legend.title = element_blank(),
      legend.text = element_text(size = 12),
      legend.position = c(0.8, 0.20),
      axis.line = element_blank(),
      panel.border = element_rect(fill = NA, linewidth = 0.6),
      panel.background = element_rect(fill = "white"),
      plot.background  = element_rect(fill = "white"),
      text = element_text(size = 14, family = "Times New Roman")
    )
}
