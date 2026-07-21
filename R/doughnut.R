#' Doughnut Economics chart (the safe and just space at one instant)
#'
#' Draws the Doughnut in its canonical form: an inner ring of social foundation
#' dimensions whose shortfalls bite *inward* toward the hole, an outer ring of
#' ecological ceiling dimensions whose overshoots break *outward* past the
#' boundary, and the green safe and just space between them. The two rings carry
#' independent dimension sets, so a 12-dimension social foundation and a
#' 9-dimension ecological ceiling divide the circle differently, exactly as in
#' Raworth's figure.
#'
#' This is the polar snapshot half of the grammar, the boundary at a single
#' instant. See [geom_boundary()] for the Cartesian trajectory that restores the
#' time derivative the Doughnut necessarily lacks.
#'
#' @param social data.frame of social foundation dimensions, one row each, with a
#'   label column and a shortfall column scaled 0 (fully met) to 1 (total
#'   shortfall). `NA` marks a dimension whose boundary is not quantified.
#' @param ecological data.frame of ecological ceiling dimensions, one row each,
#'   with a label column and an overshoot column, 0 meaning within the boundary
#'   and larger values further beyond it. `NA` marks a boundary not quantified.
#' @param dimension name of the label column, used in both data frames.
#' @param shortfall name of the shortfall column in `social`.
#' @param overshoot name of the overshoot column in `ecological`.
#' @param title optional plot title.
#' @param safe_fill,ring_fill fill for the safe and just space and for the two
#'   boundary bands.
#' @param hole_fill fill for the centre of the Doughnut.
#' @param breach_fill fill for shortfall and overshoot wedges.
#' @param unquantified_fill fill for dimensions whose boundary is not quantified.
#' @param label_size,ring_label_size text sizes for dimension labels and for the
#'   two band labels.
#' @return a ggplot object.
#' @examples
#' social <- data.frame(
#'   dimension = c("water", "food", "health", "education", "income & work",
#'                 "peace & justice", "political voice", "social equity",
#'                 "gender equality", "housing", "networks", "energy"),
#'   shortfall = c(0.36, 0.29, 0.34, 0.44, 0.53, 0.42,
#'                 0.53, 0.39, 0.40, 0.24, 0.24, 0.38))
#' ecological <- data.frame(
#'   dimension = c("climate change", "ocean acidification", "chemical pollution",
#'                 "nitrogen & phosphorus loading", "freshwater withdrawals",
#'                 "land conversion", "biodiversity loss", "air pollution",
#'                 "ozone layer depletion"),
#'   overshoot = c(0.85, 0.30, NA, 1.00, 0.20, 0.60, 0.95, NA, 0))
#' doughnut(social, ecological, title = "A global Doughnut")
#' @export
doughnut <- function(social, ecological,
                     dimension = "dimension",
                     shortfall = "shortfall",
                     overshoot = "overshoot",
                     title = NULL,
                     safe_fill = "#6FCB1E",
                     ring_fill = "#1F9E2E",
                     hole_fill = "#D9D9D9",
                     breach_fill = "#F5121E",
                     unquantified_fill = "#C9D3DC",
                     label_size = 2.4,
                     ring_label_size = 2.4) {
  requireNamespace("ggplot2", quietly = TRUE)
  stopifnot(is.data.frame(social), is.data.frame(ecological))

  # Radial layout, in a 0-1 space that coord_polar reads as distance from centre.
  r_hole <- 0.44   # centre, where shortfalls are drawn
  r_sf   <- 0.55   # outer edge of the social foundation band
  r_safe <- 0.80   # outer edge of the safe and just space
  r_ec   <- 0.91   # outer edge of the ecological ceiling band
  over_len <- 0.42 # radial room given to the largest overshoot

  # Long dimension names are wrapped onto two lines. At twelve wedges the arc
  # available to each label is shorter than names like "gender equality", so
  # unwrapped text collides with its neighbours around the bottom of the ring.
  wrap2 <- function(s, max_chars = 11) {
    vapply(s, function(z) {
      if (is.na(z) || nchar(z) <= max_chars || !grepl(" ", z)) return(z)
      sp <- gregexpr(" ", z, fixed = TRUE)[[1]]
      cut <- sp[which.min(abs(sp - nchar(z) / 2))]
      paste0(substr(z, 1, cut - 1), "\n", substr(z, cut + 1, nchar(z)))
    }, character(1), USE.NAMES = FALSE)
  }

  s_lab <- as.character(social[[dimension]])
  e_lab <- as.character(ecological[[dimension]])
  s_val <- as.numeric(social[[shortfall]])
  e_val <- as.numeric(ecological[[overshoot]])
  ks <- length(s_lab); ke <- length(e_lab)
  if (ks < 1 || ke < 1) stop("`social` and `ecological` each need at least one row.")

  band <- function(ymin, ymax, type)
    data.frame(xmin = 0, xmax = 1, ymin = ymin, ymax = ymax, type = type)

  # Centre: one segment per social dimension, so the white edges read as the
  # radial dividers of Raworth's hole.
  hole <- data.frame(
    xmin = (seq_len(ks) - 1) / ks, xmax = seq_len(ks) / ks,
    ymin = 0, ymax = r_hole,
    type = ifelse(is.na(s_val), "unquantified", "hole"))

  # Shortfalls bite inward from the social foundation toward the centre.
  s_keep <- !is.na(s_val) & s_val > 0
  short <- if (any(s_keep)) data.frame(
    xmin = ((seq_len(ks) - 1) / ks)[s_keep], xmax = (seq_len(ks) / ks)[s_keep],
    ymin = r_hole * (1 - pmin(s_val[s_keep], 1)), ymax = r_hole,
    type = "breach") else NULL

  # Overshoots break outward past the ecological ceiling. Unquantified
  # boundaries get a fixed, visibly pale wedge rather than a length claim.
  e_max <- suppressWarnings(max(e_val, na.rm = TRUE))
  if (!is.finite(e_max) || e_max <= 0) e_max <- 1
  e_len <- ifelse(is.na(e_val), over_len * 0.45, over_len * (e_val / e_max))
  e_keep <- e_len > 0
  over <- if (any(e_keep)) data.frame(
    xmin = ((seq_len(ke) - 1) / ke)[e_keep], xmax = (seq_len(ke) / ke)[e_keep],
    ymin = r_ec, ymax = (r_ec + e_len)[e_keep],
    type = ifelse(is.na(e_val), "unquantified", "breach")[e_keep]) else NULL

  rings <- rbind(band(r_hole, r_sf, "foundation"),
                 band(r_sf, r_safe, "safe"),
                 band(r_safe, r_ec, "ceiling"))
  wedges <- rbind(hole, short, over)

  # Tangential text, flipped on the lower half so nothing reads upside down.
  tang <- function(f) {
    a <- -360 * f
    ifelse(f > 0.25 & f < 0.75, a + 180, a)
  }
  fs <- (seq_len(ks) - 0.5) / ks
  fe <- (seq_len(ke) - 0.5) / ke
  y_top <- r_ec + over_len + 0.20
  s_txt <- data.frame(x = fs, y = (r_sf + r_safe) / 2,
                      lab = wrap2(s_lab), ang = tang(fs))
  e_txt <- data.frame(x = fe, y = r_ec + over_len + 0.07,
                      lab = wrap2(e_lab, 14), ang = tang(fe))
  band_txt <- data.frame(
    x = c(0, 0), y = c((r_hole + r_sf) / 2, (r_safe + r_ec) / 2),
    lab = c("SOCIAL FOUNDATION", "ECOLOGICAL CEILING"))

  pal <- c(hole = hole_fill, foundation = ring_fill, safe = safe_fill,
           ceiling = ring_fill, breach = breach_fill,
           unquantified = unquantified_fill)

  ggplot2::ggplot() +
    ggplot2::geom_rect(data = rings, ggplot2::aes(
      xmin = .data$xmin, xmax = .data$xmax, ymin = .data$ymin,
      ymax = .data$ymax, fill = .data$type)) +
    ggplot2::geom_rect(data = wedges, colour = "white", linewidth = 0.35,
      ggplot2::aes(xmin = .data$xmin, xmax = .data$xmax, ymin = .data$ymin,
                   ymax = .data$ymax, fill = .data$type)) +
    ggplot2::geom_text(data = s_txt, colour = "white", size = label_size,
      fontface = "bold", ggplot2::aes(x = .data$x, y = .data$y,
                                      label = .data$lab, angle = .data$ang)) +
    ggplot2::geom_text(data = e_txt, colour = "#1a1a1a", size = label_size,
      fontface = "bold", ggplot2::aes(x = .data$x, y = .data$y,
                                      label = .data$lab, angle = .data$ang)) +
    ggplot2::geom_text(data = band_txt, colour = "white", size = ring_label_size,
      fontface = "bold", ggplot2::aes(x = .data$x, y = .data$y, label = .data$lab)) +
    ggplot2::scale_fill_manual(
      values = pal, name = NULL,
      breaks = c("breach", "unquantified"),
      labels = c("beyond the boundary", "boundary not quantified")) +
    ggplot2::coord_polar(theta = "x", clip = "off") +
    ggplot2::scale_y_continuous(limits = c(0, y_top)) +
    ggplot2::scale_x_continuous(limits = c(0, 1)) +
    ggplot2::labs(title = title) +
    ggplot2::theme_void(base_size = 11) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, face = "bold",
                                         margin = ggplot2::margin(b = 4)),
      legend.position = "bottom",
      legend.margin = ggplot2::margin(t = -6),
      plot.margin = ggplot2::margin(6, 6, 6, 6))
}
