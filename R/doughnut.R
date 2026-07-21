#' Doughnut Economics chart (static safe operating space)
#'
#' The Raworth doughnut proper: a green safe band between a `floor` (social
#' foundation) and a `ceiling` (ecological limit). Each dimension shows only its
#' deviation, shortfalls bite *inward* from the floor toward the hole, overshoots
#' break *outward* past the ceiling. This is the polar snapshot half of the
#' grammar, the boundary at a single instant; see [geom_boundary()] for the
#' Cartesian trajectory that restores the time derivative the doughnut lacks.
#'
#' @param data data.frame, one row per dimension.
#' @param dimension name of the label column.
#' @param value name of the value column (same scale as floor/ceiling).
#' @param floor,ceiling safe-band bounds.
#' @param title optional plot title.
#' @return a ggplot object.
#' @examples
#' d <- data.frame(dim = c("water", "food", "energy", "income"),
#'                 v = c(0.2, 0.5, 0.8, 0.45))
#' doughnut(d, "dim", "v")
#' @export
doughnut <- function(data, dimension, value, floor = 0.33, ceiling = 0.66,
                     title = NULL) {
  requireNamespace("ggplot2", quietly = TRUE)
  d <- data.frame(dim = factor(data[[dimension]], levels = data[[dimension]]),
                  val = as.numeric(data[[value]]))
  k <- nrow(d); d$i <- seq_len(k)
  seg <- function(i, ymin, ymax, type)
    data.frame(xmin = i - 0.5, xmax = i + 0.5, ymin = ymin, ymax = ymax, type = type)
  rects <- do.call(rbind, lapply(seq_len(k), function(r) {
    v <- d$val[r]; out <- seg(r, floor, ceiling, "safe")
    if (v < floor)   out <- rbind(out, seg(r, v, floor, "shortfall"))
    if (v > ceiling) out <- rbind(out, seg(r, ceiling, v, "overshoot"))
    out
  }))
  pal <- c(safe = "#cfe0b8", shortfall = "#e2843a", overshoot = "#c1121f")
  top <- max(ceiling, max(d$val))
  lab <- data.frame(i = d$i, dim = d$dim, y = top * 1.16)
  ggplot2::ggplot() +
    ggplot2::geom_rect(data = rects, colour = "white", linewidth = 0.2,
      ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = type)) +
    ggplot2::geom_hline(yintercept = c(floor, ceiling), colour = "#5c4a36",
      linetype = 2, linewidth = 0.4) +
    ggplot2::geom_text(data = lab, size = 2.5, colour = "#3a2f26",
      ggplot2::aes(x = i, y = y, label = dim)) +
    ggplot2::scale_fill_manual(values = pal, name = NULL,
      breaks = c("shortfall", "safe", "overshoot")) +
    ggplot2::coord_polar(theta = "x", clip = "off") +
    ggplot2::ylim(-top * 0.35, top * 1.28) +
    ggplot2::labs(title = title) + ggplot2::theme_void() +
    ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5),
                   legend.position = "bottom")
}
