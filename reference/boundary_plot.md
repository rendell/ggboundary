# Trajectory-against-boundary plot (themed one-call wrapper)

Assembles a complete, lightly themed plot around
[`geom_boundary()`](https://rendell.github.io/ggboundary/reference/geom_boundary.md)
for users who want a figure in one call rather than composing layers.
The share of the series spent in overshoot is reported in the caption.

## Usage

``` r
boundary_plot(data, x, value, boundary, title = NULL, y_lab = NULL, ...)
```

## Arguments

- data:

  a data.frame.

- x, value, boundary:

  column names (character) in `data`. `boundary` may instead be a single
  numeric value for a fixed ceiling.

- title, y_lab:

  optional plot title and y-axis label.

- ...:

  passed to
  [`geom_boundary()`](https://rendell.github.io/ggboundary/reference/geom_boundary.md).

## Value

a ggplot object.

## Examples

``` r
df <- data.frame(year = 2016:2025,
                 hhi = c(38,40,41,43,45,47,49,52,54,55), cap = 50)
boundary_plot(df, "year", "hhi", "cap", title = "Concentration vs ceiling")
```
