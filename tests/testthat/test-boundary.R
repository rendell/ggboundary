test_that("geom_boundary returns ggplot layers and composes", {
  df <- data.frame(year = 2016:2025, v = seq(38, 55, length.out = 10), cap = 50)
  ly <- geom_boundary(df, "year", "v", "cap")
  expect_type(ly, "list")
  expect_true(all(vapply(ly, ggplot2::is.ggproto, logical(1)) |
                  vapply(ly, function(x) inherits(x, "LayerInstance"), logical(1))))
  p <- ggplot2::ggplot() + ly
  expect_s3_class(p, "ggplot")
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("scalar and vector boundaries both work; bad length errors", {
  df <- data.frame(year = 2016:2020, v = c(1, 2, 3, 4, 5))
  expect_type(geom_boundary(df, "year", "v", 3), "list")
  expect_type(geom_boundary(df, "year", "v", c(1, 2, 3, 4, 5)), "list")
  expect_error(geom_boundary(df, "year", "v", c(1, 2)))
})

test_that("show_slack toggles a layer", {
  df <- data.frame(year = 2016:2020, v = c(1, 2, 3, 4, 5), cap = 3)
  expect_lt(length(geom_boundary(df, "year", "v", "cap", show_slack = FALSE)),
            length(geom_boundary(df, "year", "v", "cap", show_slack = TRUE)))
})

test_that("boundary_plot reports overshoot share in the caption", {
  df <- data.frame(year = 2016:2025, v = seq(38, 55, length.out = 10), cap = 50)
  p <- boundary_plot(df, "year", "v", "cap")
  expect_s3_class(p, "ggplot")
  expect_match(p$labels$caption, "overshoot")
})

test_that("doughnut and conch build", {
  d <- data.frame(dim = c("a", "b", "c"), v = c(0.2, 0.5, 0.8))
  expect_s3_class(doughnut(d, "dim", "v"), "ggplot")
  expect_s3_class(conch(2016:2025, seq(38, 55, length.out = 10), 50), "ggplot")
})

test_that("conch labels are formatted, not raw floats", {
  p <- conch(2016:2025 + 0.9166, seq(38, 55, length.out = 10), 50, label_fmt = round)
  txt <- p$layers[[length(p$layers)]]$data$yr
  expect_false(any(grepl("\\.\\d{3,}", txt)))
})
