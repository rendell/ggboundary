#' Draw a trajectory against a (possibly moving) boundary
#'
#' The core layer of the package. Given a value trajectory over an ordered axis
#' (usually time) and a `boundary`, `geom_boundary()` shades the region where
#' the value overshoots the boundary and, optionally, the slack below it, then
#' draws the value line and the boundary line on top. The boundary may be a
#' single number (a fixed ceiling) or a vector the same length as the data (a
#' boundary that itself moves over time).
#'
#' The moving boundary is the point of the package. Doughnut Economics and the
#' planetary-boundaries framework draw the safe threshold as a fixed ring; a
#' complex-adaptive-systems and dynamic-capabilities reading treats it as
#' endogenous, a function of the system's own adaptive capacity, so it belongs
#' in the plot as its own series rather than as a constant. Passing a vector to
#' `boundary` puts that choice on the page.
#'
#' Returns a list of ggplot2 layers, so add it to a `ggplot()` and combine it
#' with any scales, facets, and themes as usual. See [boundary_plot()] for a
#' one-call themed wrapper, and [doughnut()] for the polar single-instant
#' snapshot.
#'
#' @param data a data.frame.
#' @param x,value,boundary column names (character) in `data`. `boundary` may
#'   instead be a single numeric value for a fixed ceiling.
#' @param show_slack draw the slack region below the boundary (default TRUE).
#' @param over_fill,slack_fill fills for the overshoot and slack regions.
#' @param over_alpha,slack_alpha alphas for those regions.
#' @param value_colour,boundary_colour line colours.
#' @param value_size line width of the value trajectory.
#' @return a list of ggplot2 layers.
#' @examples
#' df <- data.frame(year = 2016:2025,
#'                  hhi = c(38,40,41,43,45,47,49,52,54,55),
#'                  cap = 50)
#' library(ggplot2)
#' ggplot(df) + geom_boundary(df, "year", "hhi", "cap") + theme_minimal()
#' @export
geom_boundary <- function(data, x, value, boundary,
                          show_slack = TRUE,
                          over_fill = "#c1121f", slack_fill = "#749c4c",
                          over_alpha = 0.35, slack_alpha = 0.18,
                          value_colour = "#44759e", boundary_colour = "#7a1512",
                          value_size = 0.6) {
  stopifnot(is.data.frame(data), is.character(x), is.character(value))
  # Keep every original column (facet/group variables included) so the layers
  # respond to facets and scales; only *add* the computed helper columns.
  d <- data
  d[[".ggb_val"]] <- as.numeric(data[[value]])
  if (is.character(boundary)) {
    d[[".ggb_bnd"]] <- as.numeric(data[[boundary]])
  } else {
    if (!length(boundary) %in% c(1L, nrow(d)))
      stop("`boundary` must be a column name, a single value, or one value per row.")
    d[[".ggb_bnd"]] <- rep(as.numeric(boundary), length.out = nrow(d))
  }
  d <- d[order(d[[x]]), , drop = FALSE]              # ribbons/lines follow x order
  d[[".ggb_over_hi"]]  <- pmax(d[[".ggb_val"]], d[[".ggb_bnd"]])
  d[[".ggb_slack_lo"]] <- pmin(d[[".ggb_val"]], d[[".ggb_bnd"]])

  layers <- list(
    ggplot2::geom_ribbon(data = d,
      ggplot2::aes(x = .data[[x]], ymin = .data[[".ggb_bnd"]], ymax = .data[[".ggb_over_hi"]]),
      fill = over_fill, alpha = over_alpha)
  )
  if (isTRUE(show_slack))
    layers <- c(layers, list(ggplot2::geom_ribbon(data = d,
      ggplot2::aes(x = .data[[x]], ymin = .data[[".ggb_slack_lo"]], ymax = .data[[".ggb_bnd"]]),
      fill = slack_fill, alpha = slack_alpha)))
  c(layers, list(
    ggplot2::geom_line(data = d,
      ggplot2::aes(x = .data[[x]], y = .data[[".ggb_val"]]),
      colour = value_colour, linewidth = value_size),
    ggplot2::geom_line(data = d,
      ggplot2::aes(x = .data[[x]], y = .data[[".ggb_bnd"]]),
      colour = boundary_colour, linetype = 2, linewidth = 0.5)
  ))
}

#' Trajectory-against-boundary plot (themed one-call wrapper)
#'
#' Assembles a complete, lightly themed plot around [geom_boundary()] for users
#' who want a figure in one call rather than composing layers. The share of the
#' series spent in overshoot is reported in the caption.
#'
#' @inheritParams geom_boundary
#' @param title,y_lab optional plot title and y-axis label.
#' @param ... passed to [geom_boundary()].
#' @return a ggplot object.
#' @examples
#' df <- data.frame(year = 2016:2025,
#'                  hhi = c(38,40,41,43,45,47,49,52,54,55), cap = 50)
#' boundary_plot(df, "year", "hhi", "cap", title = "Concentration vs ceiling")
#' @export
boundary_plot <- function(data, x, value, boundary,
                          title = NULL, y_lab = NULL, ...) {
  requireNamespace("ggplot2", quietly = TRUE)
  b <- if (is.character(boundary)) as.numeric(data[[boundary]]) else as.numeric(boundary)
  v <- as.numeric(data[[value]])
  share <- mean(v > b, na.rm = TRUE)
  p <- ggplot2::ggplot() +
    geom_boundary(data, x, value, boundary, ...) +
    ggplot2::labs(title = title, x = NULL, y = y_lab,
      caption = sprintf("%.0f%% of the series is in overshoot.", 100 * share)) +
    ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(panel.grid.minor = ggplot2::element_blank(),
                   plot.caption = ggplot2::element_text(colour = "#5c4a36"))
  if (requireNamespace("scales", quietly = TRUE))
    p <- p + ggplot2::scale_y_continuous(labels = scales::comma)
  p
}
