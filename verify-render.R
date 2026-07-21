# Iteration: 1
# Verify ggboundary renders on the same Aruba-calibrated data used in the ggconch
# stress test: geom_boundary (flagship), doughnut (snapshot), conch (companion).
suppressPackageStartupMessages(library(ggplot2))
set.seed(42)

hub <- "C:/Users/Rendell CE/Documents/GitHub/knowledge-hub"   # real Aruba data source
pkg <- "C:/Users/Rendell CE/Documents/GitHub/ggboundary"      # package now lives here
out <- file.path(pkg, "gallery-output")
dir.create(out, showWarnings = FALSE, recursive = TRUE)
for (f in c("boundary.R", "doughnut.R", "conch.R")) source(file.path(pkg, "R", f))

## same monthly series + moving carrying-capacity boundary as the stress test ----
real <- read.csv(file.path(hub,
  "aruba-data/datasets/tourism-monthly-visitors/monthly_stopover_visitors_2018_2020.csv"))
pre  <- subset(real, year %in% c(2018, 2019))
si   <- tapply(pre$visitors, pre$month, mean); si <- si / mean(si)

yrs <- 2016:2024
g   <- expand.grid(month = 1:12, year = yrs)
g   <- g[order(g$year, g$month), ]; n <- nrow(g)
g$t <- g$year + (g$month - 1) / 12
base <- approx(c(2016, 2019, 2020, 2021, 2024),
               c(84000, 92000, 92000, 70000, 101000), g$t, rule = 2)$y
g$visitors <- base * si[g$month]
covid <- rep(1, n)
covid[g$year == 2020 & g$month == 3]      <- 0.45
covid[g$year == 2020 & g$month %in% 4:6]  <- 0.02
covid[g$year == 2020 & g$month %in% 7:12] <- seq(0.18, 0.45, length.out = 6)
covid[g$year == 2021]                     <- seq(0.55, 0.98, length.out = 12)
g$visitors <- g$visitors * covid * rnorm(n, 1, 0.02)
g$boundary <- approx(c(2016, 2019.9, 2020.5, 2022, 2024),
                     c(93000, 99000, 99000, 94000, 98000), g$t, rule = 2)$y

## 1. flagship: geom_boundary via the one-call wrapper ----------------------
p1 <- boundary_plot(g, "t", "visitors", "boundary",
                    title = "ggboundary::boundary_plot() — Aruba arrivals vs a moving capacity ceiling",
                    y_lab = "stop-over visitors / month") +
      scale_x_continuous(breaks = yrs)
ggsave(file.path(out, "boundary.png"), p1, width = 8, height = 4.2, dpi = 150, bg = "white")

## 1b. composability: geom_boundary as a layer added to a user's own ggplot -
p1b <- ggplot(g) +
  geom_boundary(g, "t", "visitors", "boundary", show_slack = FALSE) +
  facet_wrap(~ (t >= 2020), scales = "free_x",
             labeller = as_labeller(c(`FALSE` = "pre-2020", `TRUE` = "2020 on"))) +
  labs(x = NULL, y = "visitors / month", title = "geom_boundary() composes with facets") +
  theme_minimal()
ggsave(file.path(out, "boundary_faceted.png"), p1b, width = 8, height = 4, dpi = 150, bg = "white")

## 2. doughnut snapshot ------------------------------------------------------
d <- data.frame(dim = c("water", "food", "energy", "income", "health", "jobs"),
                v = c(0.18, 0.52, 0.82, 0.44, 0.7, 0.6))
ggsave(file.path(out, "doughnut.png"),
       doughnut(d, "dim", "v", title = "doughnut(): safe operating space at one instant"),
       width = 5.2, height = 5.2, dpi = 150, bg = "white")

## 3. conch companion — bug fixes: integer year labels, no centre cram ------
p3 <- conch(time = g$t, value = g$visitors, boundary = g$boundary,
            turns = (n - 1) / 12, per_turn = 1.22, amp = 0.5,
            n_labels = length(yrs), label_fmt = round,
            title = "conch(): expressive companion (label + cram bugs fixed)")
ggsave(file.path(out, "conch.png"), p3, width = 5.6, height = 5.6, dpi = 150, bg = "white")

## inline assertions ---------------------------------------------------------
stopifnot(
  is.list(geom_boundary(g, "t", "visitors", "boundary")),
  inherits(p1, "ggplot"),
  inherits(doughnut(d, "dim", "v"), "ggplot"),
  inherits(p3, "ggplot")
)
lab_txt <- p3$layers[[length(p3$layers)]]$data$yr
cat("conch marker labels:", paste(lab_txt, collapse = " "), "\n")
stopifnot(!any(grepl("\\.\\d{3,}", lab_txt)))   # no 2024.9166... floats
cat("overshoot share:", sprintf("%.0f%%", 100 * mean(g$visitors > g$boundary)), "\n")
cat("ALL RENDERS + ASSERTIONS OK ->", out, "\n")
