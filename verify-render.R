# Iteration: 1
# Verify ggboundary renders on the same Aruba-calibrated data used in the ggconch
# stress test: geom_boundary (flagship) and doughnut (single-instant snapshot).
suppressPackageStartupMessages(library(ggplot2))
set.seed(42)

hub <- "C:/Users/Rendell CE/Documents/GitHub/knowledge-hub"   # real Aruba data source
pkg <- "C:/Users/Rendell CE/Documents/GitHub/ggboundary"      # package now lives here
out <- file.path(pkg, "gallery-output")
dir.create(out, showWarnings = FALSE, recursive = TRUE)
for (f in c("boundary.R", "doughnut.R")) source(file.path(pkg, "R", f))

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
# show_slack = FALSE: on a demand series, "far below the ceiling" is the COVID
# collapse, not a safe state, and a calm green wash there would read as reassuring.
p1 <- boundary_plot(g, "t", "visitors", "boundary",
                    show_slack = FALSE,
                    title = "Aruba arrivals against a moving capacity ceiling",
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

## 2. doughnut snapshot, canonical two-ring form -----------------------------
social <- data.frame(
  dimension = c("water", "food", "health", "education", "income & work",
                "peace & justice", "political voice", "social equity",
                "gender equality", "housing", "networks", "energy"),
  shortfall = c(0.36, 0.29, 0.34, 0.44, 0.53, 0.42,
                0.53, 0.39, 0.40, 0.24, 0.24, 0.38))
ecological <- data.frame(
  dimension = c("climate change", "ocean acidification", "chemical pollution",
                "nitrogen & phosphorus loading", "freshwater withdrawals",
                "land conversion", "biodiversity loss", "air pollution",
                "ozone layer depletion"),
  overshoot = c(0.85, 0.30, NA, 1.00, 0.20, 0.60, 0.95, NA, 0))
p2 <- doughnut(social, ecological, title = "A global Doughnut")
ggsave(file.path(out, "doughnut.png"), p2,
       width = 7.2, height = 7.2, dpi = 150, bg = "white")

## inline assertions ---------------------------------------------------------
stopifnot(
  is.list(geom_boundary(g, "t", "visitors", "boundary")),
  inherits(p1, "ggplot"),
  inherits(p2, "ggplot")
)
invisible(ggplot_build(p2))   # errors here if the polar geometry is malformed
cat("overshoot share:", sprintf("%.0f%%", 100 * mean(g$visitors > g$boundary)), "\n")
cat("ALL RENDERS + ASSERTIONS OK ->", out, "\n")
