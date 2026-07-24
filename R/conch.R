#' @rdname spiral_boundary
#' @export
conch <- function(...) spiral_boundary(...)

#' Conch: the boundary trajectory wound into a spiral (expressive companion)
#'
#' A log-spiral where the winding encodes time. A `value` trajectory grows
#' radially from the base spiral and a `boundary` (a scalar ceiling, or a full
#' series for a moving boundary) is drawn as a dashed ring; where the ribbon
#' pushes past it the system is in overshoot.
#'
#' This is deliberately an *expressive* view, kept for communication, covers,
#' and physical data objects, not an analytical instrument. In head-to-head
#' tests on real tourism data a line chart beats it on magnitude, timing, and
#' rate, and a month-by-year heatmap beats it on the phase-plus-trend read that
#' is the spiral's own supposed niche. Reach for [geom_boundary()] when the job
#' is to *see* the data; reach for the conch when the job is to make the
#' boundary idea memorable, and pair the two honestly.
#'
#' @param ... for `conch()`, arguments passed on to `spiral_boundary()`.
#' @param time numeric vector (e.g. years).
#' @param value numeric vector, same length as `time`.
#' @param boundary scalar or vector (same length as `time`) giving the ceiling.
#'   Pass a vector to express a boundary that itself moves over time.
#' @param turns number of spiral revolutions across the series.
#' @param per_turn radial growth factor per revolution.
#' @param amp radial amplitude of the value ribbon (fraction of local radius).
#' @param pal fill gradient for the value ribbon.
#' @param show_years logical; draw year markers along the spiral (default TRUE).
#' @param n_labels approximate number of markers.
#' @param min_label_frac drop markers whose radius is below this fraction of the
#'   outermost radius, so the crammed inner whorls stay unlabelled (default 0.4).
#' @param label_fmt function applied to marker values before drawing; the
#'   default rounds to one decimal. For strictly yearly data pass `round`.
#' @param title optional plot title.
#' @return a ggplot object.
#' @examples
#' conch(time = 2016:2025,
#'       value = c(38,40,41,43,45,47,49,52,54,55),
#'       boundary = 50, label_fmt = round)
#' @export
spiral_boundary <- function(time, value, boundary,
                            turns = 2.3, per_turn = 1.5, amp = 0.5,
                            pal = c("#749c4c", "#e2a32e", "#c1121f"),
                            show_years = TRUE, n_labels = 6,
                            min_label_frac = 0.4,
                            label_fmt = function(v) prettyNum(round(v, 1)),
                            title = NULL) {
  requireNamespace("ggplot2", quietly = TRUE)
  o <- order(time); time <- time[o]; value <- value[o]
  if (length(boundary) == 1) boundary <- rep(boundary, length(time))
  boundary <- boundary[o]
  b <- log(per_turn) / (2 * pi); n <- length(time)
  th0  <- seq(0, turns * 2 * pi, length.out = n)
  fine <- seq(0, turns * 2 * pi, length.out = (n - 1) * 40 + 1)
  vy <- stats::approx(th0, value, fine)$y
  by <- stats::approx(th0, boundary, fine)$y
  rng <- range(c(vy, by), na.rm = TRUE)            # unit-agnostic: scale value+boundary together
  s <- function(v) (v - rng[1]) / (rng[2] - rng[1] + 1e-9)
  rb <- exp(b * fine); rt <- rb * (1 + amp * s(vy)); rc <- rb * (1 + amp * s(by))
  m <- length(fine)
  segs <- data.frame(
    group = rep(seq_len(m - 1), each = 4),
    over  = rep((vy - by)[-m], each = 4),   # signed distance to boundary: <0 safe, >0 overshoot
    x = as.vector(rbind(rb[-m]*cos(fine[-m]), rb[-1]*cos(fine[-1]),
                        rt[-1]*cos(fine[-1]), rt[-m]*cos(fine[-m]))),
    y = as.vector(rbind(rb[-m]*sin(fine[-m]), rb[-1]*sin(fine[-1]),
                        rt[-1]*sin(fine[-1]), rt[-m]*sin(fine[-m]))))
  ring <- data.frame(x = rc * cos(fine), y = rc * sin(fine))
  # year markers along the spiral so the time axis is legible
  li  <- unique(c(seq(1, n, by = max(1, round(n / n_labels))), n))
  lr  <- exp(b * th0[li]) * (1 + amp * s(value[li]))
  keep <- lr >= min_label_frac * max(rt, na.rm = TRUE)   # drop crammed inner whorls
  li <- li[keep]; lr <- lr[keep]
  lab <- data.frame(x = lr * cos(th0[li]), y = lr * sin(th0[li]),
                    yr = vapply(time[li], function(v) as.character(label_fmt(v)),
                                character(1)))
  p <- ggplot2::ggplot() +
    ggplot2::geom_polygon(data = segs,
      ggplot2::aes(x = .data$x, y = .data$y, group = .data$group, fill = .data$over),
      colour = NA) +
    ggplot2::geom_path(data = ring, ggplot2::aes(x = .data$x, y = .data$y),
      linetype = 2, colour = "#7a1512", linewidth = 0.5) +
    ggplot2::scale_fill_gradient2(low = pal[1], mid = "#efe6cf",
      high = pal[length(pal)], midpoint = 0, name = "vs boundary") +
    ggplot2::coord_fixed(clip = "off") + ggplot2::labs(title = title) +
    ggplot2::theme_void() +
    ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))
  if (show_years && nrow(lab) > 0) p <- p +
    ggplot2::geom_segment(data = lab,
      ggplot2::aes(x = .data$x * 1.006, y = .data$y * 1.006,
                   xend = .data$x * 1.05, yend = .data$y * 1.05),
      colour = "#3a2f26", linewidth = 0.3) +
    ggplot2::geom_text(data = lab,
      ggplot2::aes(x = .data$x * 1.11, y = .data$y * 1.11, label = .data$yr),
      size = 2.5, colour = "#3a2f26")
  p
}
