test_that("malls can be created and accessed", {
  backend <- storr::storr(storr::driver_environment())
  mall <- new_mall(list(
    a = new_storefront("test", backend),
    b = new_storefront("test2", backend)
  ))
  expect_snapshot(print(mall))
  expect_snapshot(mall$a <- 1, error = TRUE)
  expect_snapshot(mall[1], error = TRUE)
  expect_snapshot(mall[1] <- 1, error = TRUE)
})
