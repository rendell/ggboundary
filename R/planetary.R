#' Planetary-boundary status as an ecological ceiling
#'
#' A thin adapter that turns a table of planetary-boundary status into the
#' `ecological` data frame [doughnut()] expects, so the Doughnut's ecological
#' ceiling can be driven from real boundary data rather than hand-entered
#' overshoots. It reads either normalised control variables (the Stockholm
#' Resilience Centre / Richardson et al. convention) or raw value-and-threshold
#' pairs, and returns one row per boundary with a `dimension` label and an
#' `overshoot` (0 within the boundary, larger beyond it).
#'
#' Two input forms:
#'
#' * **Normalised** (default, `boundary = NULL`). The `value` column holds the
#'   control variable normalised so that the Holocene baseline sits at 0 and the
#'   planetary boundary sits at `at` (1 by convention). This is the scale used in
#'   the published planetary-boundaries figures and produced by the Potsdam
#'   Institute `boundaries` package when control variables are normalised so the
#'   boundary has the same radius for every process. Overshoot is
#'   `pmax(0, value - at)`.
#' * **Raw**. Give a `boundary` column name (or a single number, or one number
#'   per row) alongside a raw `value`. Overshoot is `value / boundary - 1` when
#'   `relative = TRUE` (the sensible default, since control variables carry
#'   different units) or `value - boundary` when `relative = FALSE`, clamped at 0.
#'
#' `NA` values pass through as `NA`, so a boundary that is not quantified stays
#' pale in the Doughnut rather than being drawn as if it were within the safe
#' space.
#'
#' This does not reproduce the Stockholm wedge diagram, and deliberately so: that
#' single-instant status wheel is already served by the Potsdam Institute
#' `boundaries` package (`plot_status()`), and drawing it a second time here would
#' add a static snapshot to a package whose point is that the boundary moves. Use
#' this to feed the ceiling; use [geom_boundary()] to put the same boundaries back
#' on a time axis.
#'
#' @param data a data.frame of boundary status, one row per boundary.
#' @param dimension name of the boundary-label column.
#' @param value name of the status column: a normalised control variable when
#'   `boundary` is `NULL`, otherwise a raw control variable.
#' @param boundary optional. `NULL` for normalised input; otherwise a column name,
#'   a single number, or one number per row giving each boundary's threshold.
#' @param at in normalised input, the value that sits on the boundary (default 1).
#' @param relative in raw input, whether overshoot is measured as a ratio to the
#'   threshold (`TRUE`, default) or as a raw difference (`FALSE`).
#' @return a data.frame with columns `dimension` and `overshoot`, ready to pass to
#'   [doughnut()] as its `ecological` argument.
#' @seealso [doughnut()] for the snapshot, [geom_boundary()] for the same
#'   boundaries over time.
#' @examples
#' # Normalised control variables (0 = Holocene baseline, 1 = at the boundary).
#' # Illustrative values in the spirit of the 2023 nine-boundary assessment.
#' pb <- data.frame(
#'   boundary = c("climate change", "biosphere integrity", "land-system change",
#'                "freshwater change", "nitrogen & phosphorus", "novel entities",
#'                "ocean acidification", "aerosol loading", "ozone depletion"),
#'   value    = c(1.4, 3.0, 1.2, 1.3, 2.4, 2.0, 0.9, 0.7, 0.3))
#' eco <- planetary_boundaries(pb)
#' eco
#'
#' # Raw value against a threshold: atmospheric CO2 (ppm) vs a 350 ppm boundary.
#' raw <- data.frame(boundary = "climate change", co2 = 421, limit = 350)
#' planetary_boundaries(raw, value = "co2", boundary = "limit")
#' @export
planetary_boundaries <- function(data,
                                 dimension = "boundary",
                                 value = "value",
                                 boundary = NULL,
                                 at = 1,
                                 relative = TRUE) {
  stopifnot(is.data.frame(data))
  if (!dimension %in% names(data))
    stop("`dimension` column '", dimension, "' not found in `data`.")
  if (!value %in% names(data))
    stop("`value` column '", value, "' not found in `data`.")

  lab <- as.character(data[[dimension]])
  v   <- as.numeric(data[[value]])

  if (is.null(boundary)) {
    over <- pmax(0, v - at)                       # normalised: boundary sits at `at`
  } else {
    b <- if (is.character(boundary)) {
      if (!boundary %in% names(data))
        stop("`boundary` column '", boundary, "' not found in `data`.")
      as.numeric(data[[boundary]])
    } else {
      if (!length(boundary) %in% c(1L, length(v)))
        stop("`boundary` must be NULL, a column name, a single value, or one value per row.")
      rep(as.numeric(boundary), length.out = length(v))
    }
    over <- if (isTRUE(relative)) pmax(0, v / b - 1) else pmax(0, v - b)
  }
  over[is.na(v)] <- NA_real_                       # keep unquantified boundaries pale

  data.frame(dimension = lab, overshoot = over, stringsAsFactors = FALSE)
}
