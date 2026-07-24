# ggboundary

<!-- badges: start -->
[![R-CMD-check](https://github.com/rendell/ggboundary/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/rendell/ggboundary/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/ggboundary)](https://CRAN.R-project.org/package=ggboundary)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

A small ggplot2 grammar for reading a value trajectory against a boundary that can move.

Most "safe operating space" visuals, Doughnut Economics and the planetary-boundaries wheel among them, draw the safe threshold as a fixed line. A complex-adaptive-systems and dynamic-capabilities reading treats that threshold as endogenous: it rises and falls with the system's own adaptive capacity, so it belongs in the plot as a data series rather than a constant. `ggboundary` puts that choice on the page.

## The core: `geom_boundary()`

`geom_boundary()` shades where a trajectory overshoots its boundary and, optionally, the slack below it, then draws both lines, all on ordinary Cartesian coordinates. The boundary can be a single number or one value per row.

```r
library(ggplot2)
library(ggboundary)

df <- data.frame(
  year = 2016:2025,
  hhi  = c(38, 40, 41, 43, 45, 47, 49, 52, 54, 55),  # concentration
  cap  = c(50, 50, 51, 52, 52, 50, 48, 47, 47, 48)   # a boundary that itself moves
)

ggplot(df) +
  geom_boundary(df, x = "year", value = "hhi", boundary = "cap") +
  theme_minimal()

# or in one call:
boundary_plot(df, "year", "hhi", "cap",
              title = "Concentration against a moving ceiling")
```

## The snapshot: `doughnut()`

`doughnut()` draws the Doughnut in its canonical form. The two rings carry independent dimension sets, so a twelve-part social foundation and a nine-part ecological ceiling divide the circle differently, as in Raworth's original. Shortfalls bite inward toward the hole, overshoots break outward past the ceiling, both in red, and dimensions whose boundary is not quantified are drawn pale rather than given a length they do not have.

```r
doughnut(social, ecological, title = "A global Doughnut")
```

It is the single-instant view; `geom_boundary()` is its time-dual.

## Planetary boundaries: `planetary_boundaries()`

The Stockholm Resilience Centre draws the nine planetary boundaries as a wedge wheel, and the Doughnut takes them as its ecological ceiling. Both are single-instant status readouts. `planetary_boundaries()` turns a table of boundary status, either normalised control variables (Holocene baseline at 0, boundary at 1) or raw value-and-threshold pairs, into the `ecological` data frame `doughnut()` expects, so the ceiling is driven by data rather than typed by hand. It interoperates with the Potsdam Institute [`boundaries`](https://github.com/pik-tess/boundaries) package.

```r
pb <- data.frame(
  boundary = c("climate change", "biosphere integrity", "nitrogen & phosphorus"),
  value    = c(1.4, 3.0, 2.4))          # normalised: 1 = at the boundary
doughnut(social, planetary_boundaries(pb))
```

The package does not redraw the wedge wheel itself: that snapshot is already served by `boundaries::plot_status()`, and a second static snapshot would work against the point of the package. Instead the vignette "Planetary boundaries as moving targets" shows a boundary as a trajectory against a fixed and then a moving threshold, the view the wheel and the Doughnut structurally lack.

## The expressive companion: `conch()`

`conch()` (an alias for `spiral_boundary()`) winds the same trajectory-against-boundary idea into a log-spiral, time running around the whorls and overshoot breaking past a dashed ring. It is deliberately *not* an analytical instrument: in head-to-head tests on real tourism data a line chart read magnitude and timing better and a heatmap read phase-by-trend better, which is the spiral's own supposed niche. It stays in the package for what it is good at, communication, covers, and 3D-printed data objects, and its documentation says so. Reach for `geom_boundary()` to see the data; reach for the conch to make the boundary idea memorable, and pair the two honestly.

```r
conch(time = 2016:2025,
      value = c(38, 40, 41, 43, 45, 47, 49, 52, 54, 55),
      boundary = 50, label_fmt = round)
```

## Why this exists

The Doughnut has no time in it. This package supplies the temporal dual, and makes the exogenous-versus-endogenous boundary choice explicit, which is where the methods contribution sits. Sibling to the `pyramid3d` and tourism-data-objects work.

## Status

Pre-CRAN, version 0.1.0. `R CMD check --as-cran` is clean and the package passes on macOS, Windows, and Linux across R release, devel, and oldrel.

The four exports split cleanly by job: `geom_boundary()`/`boundary_plot()` for reading a trajectory against a moving boundary over time, `doughnut()` and `planetary_boundaries()` for the single-instant snapshot, and `conch()`/`spiral_boundary()` as the expressive companion for communication and physical data objects. The stress test that settled the conch's scope (line chart and heatmap both beat it as analysis) lives in the superseded `ggconch/` folder.
