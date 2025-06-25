test_that("storefronts can be created and are list-like", {
  backend <- storr::storr(storr::driver_environment())
  sf <- new_storefront("test", backend)
  expect_true(is_storefront(sf))
  expect_length(sf, 0)
  expect_null(sf$test)
  sf$test <- "TEST"
  expect_length(sf, 1)
  expect_equal(sf$test, "TEST")
  sf$xyz <- 1
  expect_named(sf, c("test", "xyz"))
  sf$test <- NULL
  expect_named(sf, "xyz")

  sf[c("a", "b", "c")] <- 1:3
  expect_named(sf, c("a", "b", "c", "xyz"))
  expect_equal(sf[c("a", "b", "c")], list(a = 1, b = 2, c = 3))

  expect_equal(as.list(sf), list(a = 1, b = 2, c = 3, xyz = 1))
})
