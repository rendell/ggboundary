# ggboundary

A small ggplot2 grammar for reading a value trajectory against a
boundary that can move.

Most “safe operating space” visuals, Doughnut Economics and the
planetary-boundaries wheel among them, draw the safe threshold as a
fixed line. A complex-adaptive-systems and dynamic-capabilities reading
treats that threshold as endogenous: it rises and falls with the
system’s own adaptive capacity, so it belongs in the plot as a data
series rather than a constant. `ggboundary` puts that choice on the
page.

## The core: `geom_boundary()`

[`geom_boundary()`](https://rendell.github.io/ggboundary/reference/geom_boundary.md)
shades where a trajectory overshoots its boundary and, optionally, the
slack below it, then draws both lines, all on ordinary Cartesian
coordinates. The boundary can be a single number or one value per row.

``` r

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

## Two companions, honestly framed

[`doughnut()`](https://rendell.github.io/ggboundary/reference/doughnut.md)
draws the classic Doughnut Economics chart, the same boundary primitives
at a single instant on polar coordinates. It is the snapshot;
[`geom_boundary()`](https://rendell.github.io/ggboundary/reference/geom_boundary.md)
is its time-dual.

[`conch()`](https://rendell.github.io/ggboundary/reference/spiral_boundary.md)
winds the trajectory into a log-spiral. It is an expressive object for
communication, covers, and 3D-printed data sculptures, not an analytical
instrument. On real data a line chart reads magnitude and timing better
and a heatmap reads phase-by-trend better, so the conch ships paired
with the Cartesian view rather than in place of it. The stress test that
established this lives in the superseded `ggconch/` folder.

## Why this exists

The doughnut has no time in it. This package supplies the temporal dual,
and makes the exogenous-versus-endogenous boundary choice explicit,
which is where the methods contribution sits. Sibling to the `pyramid3d`
and tourism-data-objects work.

## Status

Pre-CRAN. Core layer, doughnut, and conch build and render. Remaining
before submission: `R CMD check` clean in a full R session,
roxygen-regenerated man pages, a fuller vignette, and a pkgdown site.
