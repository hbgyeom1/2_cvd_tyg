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
                       breaks = seq(0, 12000, by = 3000),
                       labels = function(x) ifelse(x == 12000, "12,000", x)
    ) +
    labs(x = t, y = "Frequency") +
    theme(
      axis.line = element_blank(),
      panel.border = element_rect(color = "black", fill = NA, linewidth = 0.6),
      panel.background = element_rect(fill = "white", color = NA),
      plot.background  = element_rect(fill = "white", color = NA),
      text = element_text(size = 14, family = "Times New Roman")
    )
}


rcs_plot <- function(y, x, xlab) {
  kn <- svyquantile(as.formula(paste0("~", x)), des, quantiles = c(0.05, 0.275, 0.5, 0.725, 0.95)) %>% 
    coef() %>% unname()
  fml_rcs <- substitute(
    yvar ~ ns(xvar, knots = k, Boundary.knots = b) + age_g + sex + town_t +
      educ_g + ho_incm + marri_g + health_g + stress_g + drinking_g + smoking_g +
      HE_ast + HE_alt + HE_HB + HE_BUN + HE_crea + HE_Uph,
    list(yvar = as.name(y), xvar = as.name(x), k = kn[2:4], b = kn[c(1,5)])
  )
  fit <- svyglm(fml_rcs, design = des, family = quasibinomial())
  fml_lin <- substitute(
    yvar ~ xvar + age_g + sex + town_t +
      educ_g + ho_incm + marri_g + health_g + stress_g + drinking_g + smoking_g +
      HE_ast + HE_alt + HE_HB + HE_BUN + HE_crea + HE_Uph,
    list(yvar = as.name(y), xvar = as.name(x))
  )
  fit_lin <- svyglm(fml_lin, design = des, family = quasibinomial())
  fml_null <- substitute(
    yvar ~ age_g + sex + town_t +
      educ_g + ho_incm + marri_g + health_g + stress_g + drinking_g + smoking_g +
      HE_ast + HE_alt + HE_HB + HE_BUN + HE_crea + HE_Uph,
    list(yvar = as.name(y))
  )
  fit_null <- svyglm(fml_null, design = des, family = quasibinomial())
  p_overall <- anova(fit, fit_null, method = "Wald")$p
  p_nonlinear <- anova(fit, fit_lin, method = "Wald")$p
  fmt_p <- function(p) ifelse(p < 0.001, "≤ 0.001", sprintf("%.3f", p))
  p_txt <- paste0("P for overall = ", fmt_p(p_overall), 
                  "\nP for nonlinear = ", fmt_p(p_nonlinear))
  qt <- svyquantile(as.formula(paste0("~", x)), des, quantiles = c(0.01, 0.99)) %>% 
    coef() %>% unname()
  xgrid <- seq(qt[1], qt[2], length.out = 3600)
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
  ylim <- ceiling(max(upr) * 2) / 2
  ggplot() +
    geom_ribbon(aes(x = xgrid, ymin = lwr, ymax = upr), fill = "#fb4934", alpha = 0.2) +
    geom_line(aes(x = xgrid, y = OR), linewidth = 1, color = "#fb4934") +
    geom_hline(yintercept = 1, linetype = "dashed") +
    annotate("text",
             x = min(xgrid) + (max(xgrid) - min(xgrid)) * 0.05,
             y = max(ylim) * 0.95,
             label = p_txt,
             hjust = 0, vjust = 1, family = "Times New Roman", size = 5) +
    scale_x_continuous(expand = c(0, 0)) +
    scale_y_continuous(limits = c(0, ylim),
                       breaks = seq(0, ylim, by = if(ylim > 4) 1 else 0.5),
                       expand = c(0, 0),
                       labels = scales::label_number(accuracy = 0.1)) +
    labs(x = xlab, y = "Weighted Odds Ratio (95% CI)") +
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
  new_names <- sprintf("%s (AUC = %.3f)", names(rocs), as.numeric(auc_vals))
  rocs <- setNames(rocs, new_names)
  ggroc(rocs, legacy.axes = T, linewidth = 0.1) +
    geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
    guides(color = guide_legend(override.aes = list(linewidth = 0.5))) +
    scale_x_continuous(expand = c(0, 0)) +
    scale_y_continuous(expand = c(0, 0)) +
    theme(
      legend.title = element_blank(),
      legend.text = element_text(size = 11),
      # legend.key.height = unit(3, "pt"),
      legend.position = c(0.7, 0.2),
      axis.line = element_blank(),
      panel.border = element_rect(fill = NA, linewidth = 0.6),
      panel.background = element_rect(fill = "white"),
      plot.background  = element_rect(fill = "white"),
      text = element_text(size = 14, family = "Times New Roman")
    )
}


# roc_plot2 <- function(y) {
#   rocs <- lapply((c(NA, "tyg", "tyg_absi", "aip", "mets_ir")), function(x) {
#     flm <- as.formula(paste0(
#       y, " ~ ", if (is.na(x)) "" else paste0(x, " + "),
#       " + age_g + sex + town_t + educ_g + ho_incm +
#       marri_g + health_g + stress_g + drinking_g + smoking_g +
#       HE_ast + HE_alt + HE_HB + HE_BUN + HE_crea + HE_Uph"))
#     fit <- svyglm(flm, design = des, family = quasibinomial())
#     pred <- predict(fit, type = "response")
#     roc(dat[[y]], pred, quiet = T)
#   }) %>% setNames(c("Basic model", "+ TyG", "+ TyG-ABSI", "+ AIP", "+ METS-IR"))
#   auc_vals <- sapply(rocs, auc)
#   # print(auc_vals)
#   new_names <- sprintf("%s (AUC = %.3f)", names(rocs), as.numeric(auc_vals))
#   rocs <- setNames(rocs, new_names)
#   ggroc(rocs, legacy.axes = T) +
#     geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
#     scale_x_continuous(expand = c(0, 0)) +
#     scale_y_continuous(expand = c(0, 0)) +
#     labs(x = "1 - specificity", y = "Sensitivity") +
#     coord_fixed() +
#     theme(
#       legend.title = element_blank(),
#       legend.text = element_text(size = 12),
#       legend.position = c(0.8, 0.20),
#       axis.line = element_blank(),
#       panel.border = element_rect(fill = NA, linewidth = 0.6),
#       panel.background = element_rect(fill = "white"),
#       plot.background  = element_rect(fill = "white"),
#       text = element_text(size = 14, family = "Times New Roman")
#     )
# }
# 
# 
# 
# roc_plot3 <- function(y) {
#   rocs <- lapply((c("tyg_g", "tyg_absi_g", "aip_g", "mets_ir_g")), function(x) {
#     flm <- as.formula(paste0(
#       y, " ~ ", x))
#     fit <- svyglm(flm, design = des, family = quasibinomial())
#     pred <- predict(fit, type = "response")
#     roc(dat[[y]], pred, quiet = T)
#   }) %>% setNames(c("TyG", "TyG-ABSI", "AIP", "METS-IR"))
#   auc_vals <- sapply(rocs, auc)
#   # print(auc_vals)
#   new_names <- sprintf("%s (AUC = %.3f)", names(rocs), as.numeric(auc_vals))
#   rocs <- setNames(rocs, new_names)
#   ggroc(rocs, legacy.axes = T) +
#     geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
#     scale_x_continuous(expand = c(0, 0)) +
#     scale_y_continuous(expand = c(0, 0)) +
#     labs(x = "1 - specificity", y = "Sensitivity") +
#     coord_fixed() +
#     theme(
#       legend.title = element_blank(),
#       legend.text = element_text(size = 12),
#       legend.position = c(0.8, 0.20),
#       axis.line = element_blank(),
#       panel.border = element_rect(fill = NA, linewidth = 0.6),
#       panel.background = element_rect(fill = "white"),
#       plot.background  = element_rect(fill = "white"),
#       text = element_text(size = 14, family = "Times New Roman")
#     )
# }
# 
# 
# roc_plot4 <- function(y) {
#   rocs <- lapply((c("tyg", "tyg_absi", "aip", "mets_ir")), function(x) {
#     flm <- as.formula(paste0(
#       y, " ~ ", x))
#     fit <- svyglm(flm, design = des, family = quasibinomial())
#     pred <- predict(fit, type = "response")
#     roc(dat[[y]], pred, quiet = T)
#   }) %>% setNames(c("TyG", "TyG-ABSI", "AIP", "METS-IR"))
#   auc_vals <- sapply(rocs, auc)
#   # print(auc_vals)
#   new_names <- sprintf("%s (AUC = %.3f)", names(rocs), as.numeric(auc_vals))
#   rocs <- setNames(rocs, new_names)
#   ggroc(rocs, legacy.axes = T) +
#     geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
#     scale_x_continuous(expand = c(0, 0)) +
#     scale_y_continuous(expand = c(0, 0)) +
#     labs(x = "1 - specificity", y = "Sensitivity") +
#     coord_fixed() +
#     theme(
#       legend.title = element_blank(),
#       legend.text = element_text(size = 12),
#       legend.position = c(0.8, 0.20),
#       axis.line = element_blank(),
#       panel.border = element_rect(fill = NA, linewidth = 0.6),
#       panel.background = element_rect(fill = "white"),
#       plot.background  = element_rect(fill = "white"),
#       text = element_text(size = 14, family = "Times New Roman")
#     )
# }
