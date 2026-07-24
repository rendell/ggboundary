test_that("conch() builds a ggplot and is an alias for spiral_boundary()", {
  p <- conch(time = 2016:2025, value = c(38,40,41,43,45,47,49,52,54,55),
             boundary = 50, label_fmt = round)
  expect_s3_class(p, "ggplot")
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("a moving boundary (vector) is accepted", {
  p <- spiral_boundary(time = 2016:2025,
                       value = c(38,40,41,43,45,47,49,52,54,55),
                       boundary = c(50,50,51,52,52,50,48,47,47,48))
  expect_s3_class(p, "ggplot")
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("unsorted time input still builds", {
  set.seed(1)
  o <- sample(10)
  p <- conch(time = (2016:2025)[o], value = (38:47)[o], boundary = 44)
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("show_years toggles cleanly and never errors on sparse inner whorls", {
  p0 <- conch(time = 2016:2025, value = 38:47, boundary = 44, show_years = FALSE)
  expect_silent(ggplot2::ggplot_build(p0))
})
