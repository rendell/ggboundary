# Changelog

## ggboundary (development version)

- [`planetary_boundaries()`](https://rendell.github.io/ggboundary/reference/planetary_boundaries.md)
  converts a table of planetary-boundary status, either normalised
  control variables (Holocene baseline at 0, boundary at 1) or raw
  value-and-threshold pairs, into the `ecological` data frame
  [`doughnut()`](https://rendell.github.io/ggboundary/reference/doughnut.md)
  expects, so the ecological ceiling can be driven from real boundary
  data and from the output of the Potsdam Institute `boundaries`
  package.
- New vignette “Planetary boundaries as moving targets”: feeds the
  Doughnut ceiling from boundary status and shows one boundary as a
  trajectory against a fixed and then a moving threshold, the view the
  Stockholm wedge wheel and the Doughnut structurally lack.
- [`conch()`](https://rendell.github.io/ggboundary/reference/spiral_boundary.md)
  (alias
  [`spiral_boundary()`](https://rendell.github.io/ggboundary/reference/spiral_boundary.md))
  winds the trajectory-against-boundary idea into a log-spiral. It ships
  as an explicitly expressive companion for communication, covers, and
  physical data objects, not as an analytical instrument, matching the
  scope the DESCRIPTION already stated. The earlier cut applied to
  selling it as analysis; its documentation continues to refuse that.

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
- A log-spiral companion
  ([`conch()`](https://rendell.github.io/ggboundary/reference/spiral_boundary.md))
  was cut before release. On real data a line chart reads magnitude and
  timing better and a heatmap reads phase-by-trend better, so it did not
  earn a place as an analytical geom.
