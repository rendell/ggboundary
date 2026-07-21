# Doughnut Economics chart (static safe operating space)

The Raworth doughnut proper: a green safe band between a `floor` (social
foundation) and a `ceiling` (ecological limit). Each dimension shows
only its deviation, shortfalls bite *inward* from the floor toward the
hole, overshoots break *outward* past the ceiling. This is the polar
snapshot half of the grammar, the boundary at a single instant; see
[`geom_boundary()`](https://rendell.github.io/ggboundary/reference/geom_boundary.md)
for the Cartesian trajectory that restores the time derivative the
doughnut lacks.

## Usage

``` r
doughnut(data, dimension, value, floor = 0.33, ceiling = 0.66, title = NULL)
```

## Arguments

- data:

  data.frame, one row per dimension.

- dimension:

  name of the label column.

- value:

  name of the value column (same scale as floor/ceiling).

- floor, ceiling:

  safe-band bounds.

- title:

  optional plot title.

## Value

a ggplot object.

## Examples

``` r
d <- data.frame(dim = c("water", "food", "energy", "income"),
                v = c(0.2, 0.5, 0.8, 0.45))
doughnut(d, "dim", "v")
```
