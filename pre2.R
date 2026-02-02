setwd("C:/Users/user/Documents/2_cvd_tyg")
library(data.table);library(haven);library(magrittr)

dd <- read_sas("C:/Users/user/Documents/2_cvd_tyg/data/dd.sas7bdat") %>% setDT()
n_count <- colSums(is.na(dd));n_count
dd <- dd[complete.cases(dd)]

fwrite(dd, "C:/Users/user/Documents/2_cvd_tyg/data/dd.csv")


library(ggplot2);library(patchwork);library(officer);library(rvg)

p1 <- ggplot(dd, aes(x = tyg)) +
  geom_histogram(
    bins = 30,
    fill = "#fe8019",
    color = "black") +
  geom_vline(
    xintercept = median(dd$tyg, na.rm = TRUE),
    linetype = "dashed",
    color = "red") +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  labs(x = "TyG", y = "Frequency") +
  theme(
    axis.line = element_blank(),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 0.6),
    panel.background = element_rect(fill = "white", color = NA),
    plot.background  = element_rect(fill = "white", color = NA))

p2 <- ggplot(dd, aes(x = tyg_absi)) +
  geom_histogram(
    bins = 30,
    fill = "#fe8019",
    color = "black") +
  geom_vline(
    xintercept = median(dd$tyg_absi, na.rm = TRUE),
    linetype = "dashed",
    color = "red") +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  labs(x = "TyG-ABSI", y = "Frequency") +
  theme(
    axis.line = element_blank(),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 0.6),
    panel.background = element_rect(fill = "white", color = NA),
    plot.background  = element_rect(fill = "white", color = NA))

p3 <- ggplot(dd, aes(x = aip)) +
  geom_histogram(
    bins = 30,
    fill = "#fe8019",
    color = "black") +
  geom_vline(
    xintercept = median(dd$aip, na.rm = TRUE),
    linetype = "dashed",
    color = "red") +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  labs(x = "AIP", y = "Frequency") +
  theme(
    axis.line = element_blank(),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 0.6),
    panel.background = element_rect(fill = "white", color = NA),
    plot.background  = element_rect(fill = "white", color = NA))

p4 <- ggplot(dd, aes(x = mets_ir)) +
  geom_histogram(
    bins = 30,
    fill = "#fe8019",
    color = "black") +
  geom_vline(
    xintercept = median(dd$mets_ir, na.rm = TRUE),
    linetype = "dashed",
    color = "red") +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  labs(x = "METS-IR", y = "Frequency") +
  theme(
    axis.line = element_blank(),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 0.6),
    panel.background = element_rect(fill = "white", color = NA),
    plot.background  = element_rect(fill = "white", color = NA))

y_scale <- scale_y_continuous(
  limits = c(0, 15000),
  expand = expansion(mult = c(0, 0.05)),
  breaks = seq(0, 15000, by = 3000)
)

p1 <- p1 + y_scale
p2 <- p2 + y_scale
p3 <- p3 + y_scale
p4 <- p4 + y_scale

f1 <- p1 + p2 + p3 + p4 + plot_layout(axes = "collect", axis_titles = "collect")

# read_pptx() %>%
#   add_slide(layout = "Title and Content", master = "Office Theme") %>%
#   ph_with(
#     dml(ggobj = f1),
#     location = ph_location_fullsize()
#   ) %>%
#   print(target = "figure/figure1.pptx")

library(rms)

ddist <- datadist(dd)
options(datadist = "ddist")

rcs_plot <- function(y, x) {
  fit <- lrm(as.formula(paste0(y, " ~ rcs(", x, ", 4)")), data = dd)
  p <- Predict(fit, name = x, ref.zero = TRUE, fun = exp)
  ix <- p[[x]][which.min(abs(p$yhat - 1))]
  rcs <- ggplot(p, aes(x = .data[[x]], y = yhat)) +
    geom_ribbon(aes(ymin = lower, ymax = upper), fill = "#83a598", alpha = 0.2) +
    geom_line(linewidth = 1, color = "#83a598") +
    geom_hline(yintercept = 1, linetype = "dashed") +
    geom_vline(xintercept = ix, linetype = "dashed", color = "red") +
    scale_x_continuous(expand = c(0, 0)) +
    scale_y_continuous(expand = c(0, 0)) +
    labs(
      x = x,
      y = "Odds Ratio"
    ) +
    theme(
      axis.line = element_blank(),
      panel.border = element_rect(fill = NA, linewidth = 0.6),
      panel.background = element_rect(fill = "white"),
      plot.background  = element_rect(fill = "white")
    )
  return(rcs)
}

rcs1 <- rcs_plot("hypertension_g", "tyg")
rcs2 <- rcs_plot("hypertension_g", "tyg_absi")
rcs3 <- rcs_plot("hypertension_g", "aip")
rcs4 <- rcs_plot("hypertension_g", "mets_ir")

f2 <- rcs1 + rcs2 + rcs3 + rcs4 + plot_layout(axes = "collect", axis_titles = "collect")

rcs1 <- rcs_plot("dyslipidemia_g", "tyg")
rcs2 <- rcs_plot("dyslipidemia_g", "tyg_absi")
rcs3 <- rcs_plot("dyslipidemia_g", "aip")
rcs4 <- rcs_plot("dyslipidemia_g", "mets_ir")

f3 <- rcs1 + rcs2 + rcs3 + rcs4 + plot_layout(axes = "collect", axis_titles = "collect")

rcs1 <- rcs_plot("stroke_g", "tyg")
rcs2 <- rcs_plot("stroke_g", "tyg_absi")
rcs3 <- rcs_plot("stroke_g", "aip")
rcs4 <- rcs_plot("stroke_g", "mets_ir")

f4 <- rcs1 + rcs2 + rcs3 + rcs4 + plot_layout(axes = "collect", axis_titles = "collect")

rcs1 <- rcs_plot("mi_g", "tyg")
rcs2 <- rcs_plot("mi_g", "tyg_absi")
rcs3 <- rcs_plot("mi_g", "aip")
rcs4 <- rcs_plot("mi_g", "mets_ir")

f5 <- rcs1 + rcs2 + rcs3 + rcs4 + plot_layout(axes = "collect", axis_titles = "collect")

rcs1 <- rcs_plot("angina_g", "tyg")
rcs2 <- rcs_plot("angina_g", "tyg_absi")
rcs3 <- rcs_plot("angina_g", "aip")
rcs4 <- rcs_plot("angina_g", "mets_ir")

f6 <- rcs1 + rcs2 + rcs3 + rcs4 + plot_layout(axes = "collect", axis_titles = "collect")