# Changelog

## ggboundary 0.1.0

First release.

- [`geom_boundary()`](https://rendell.github.io/ggboundary/reference/geom_boundary.md)
  shades overshoot and slack between a value trajectory and a fixed or
  moving boundary on Cartesian coordinates, as a facet-safe list of
  ggplot2 layers.
- [`boundary_plot()`](https://rendell.github.io/ggboundary/reference/boundary_plot.md)
  wraps it into a themed one-call figure and reports the share of the
  series in overshoot.
- [`doughnut()`](https://rendell.github.io/ggboundary/reference/doughnut.md)
  draws the Doughnut in its canonical form: independent social
  foundation and ecological ceiling rings, shortfalls biting inward,
  overshoots breaking outward, and unquantified boundaries drawn pale.
- A log-spiral companion (`conch()`) was cut before release. On real
  data a line chart reads magnitude and timing better and a heatmap
  reads phase-by-trend better, so it did not earn a place as an
  analytical geom.
