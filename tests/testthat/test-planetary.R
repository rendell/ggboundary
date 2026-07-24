test_that("normalised input maps boundary=1 to zero overshoot and beyond to positive", {
  pb <- data.frame(boundary = c("a", "b", "c"), value = c(0.4, 1.0, 2.5))
  eco <- planetary_boundaries(pb)
  expect_named(eco, c("dimension", "overshoot"))
  expect_equal(eco$overshoot, c(0, 0, 1.5))
})

test_that("raw input measures overshoot relative to the threshold by default", {
  raw <- data.frame(boundary = c("climate", "safe"), co2 = c(420, 300), limit = c(350, 350))
  eco <- planetary_boundaries(raw, value = "co2", boundary = "limit")
  expect_equal(eco$overshoot, c(420 / 350 - 1, 0))
})

test_that("raw input can measure an absolute difference", {
  raw <- data.frame(boundary = "x", v = 12, b = 10)
  expect_equal(planetary_boundaries(raw, value = "v", boundary = "b", relative = FALSE)$overshoot, 2)
})

test_that("scalar boundary recycles across rows", {
  raw <- data.frame(boundary = c("x", "y"), v = c(15, 5))
  eco <- planetary_boundaries(raw, value = "v", boundary = 10, relative = FALSE)
  expect_equal(eco$overshoot, c(5, 0))
})

test_that("NA status stays NA so the boundary reads as unquantified", {
  pb <- data.frame(boundary = c("a", "b"), value = c(NA, 1.6))
  expect_equal(planetary_boundaries(pb)$overshoot, c(NA, 0.6))
})

test_that("output feeds doughnut() directly", {
  social <- data.frame(dimension = c("water", "food"), shortfall = c(0.3, 0.1))
  pb <- data.frame(boundary = c("climate", "land", "nitrogen"), value = c(1.4, 1.2, 2.4))
  p <- doughnut(social, planetary_boundaries(pb))
  expect_s3_class(p, "ggplot")
  expect_silent(ggplot2::ggplot_build(p))
})

test_that("missing columns and bad boundary length error", {
  pb <- data.frame(boundary = "a", value = 1)
  expect_error(planetary_boundaries(pb, dimension = "nope"))
  expect_error(planetary_boundaries(pb, value = "nope"))
  raw <- data.frame(boundary = c("a", "b"), v = c(1, 2))
  expect_error(planetary_boundaries(raw, value = "v", boundary = c(1, 2, 3)))
})
