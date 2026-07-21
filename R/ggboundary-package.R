#' @keywords internal
"_PACKAGE"

#' @importFrom ggplot2 .data
NULL

# aes() references to columns in package-internal data frames (doughnut(),
# conch()); declared here so R CMD check does not flag them as undefined globals.
utils::globalVariables(c(
  "x", "y", "xmin", "xmax", "ymin", "ymax", "type", "i", "dim",
  "group", "over", "xend", "yend", "yr"
))
