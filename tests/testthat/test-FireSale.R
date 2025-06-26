test_that("multiplication works", {
  fs <- FireSale$new(storr::driver_environment(), max_age = 2)
  expect_equal(fs$name, "firesale")
  expect_snapshot(print(fs))

  mall <- fs$get_mall("test")
  expect_named(mall, c("global", "session"))
  expect_s3_class(mall, "firesale_mall")

  expect_s3_class(fs$.__enclos_env__$private$STORR$get("test", "_id_access"), "POSIXct")

  skip_if_not_installed("fiery")
  app <- fiery::Fire$new()
  app$attach(fs)

  app$on("request", function(arg_list, ...) {
    arg_list$datastore$global$test <- "test"
    arg_list$datastore$session$test2 <- "test2"
  })

  req <- fiery::fake_request("http://127.0.0.1:8080/set_val")
  res <- app$test_request(req)
  id <- sub("^fiery_id=(.*?);.*$", "\\1", res$headers$`set-cookie`)
  mall <- fs$get_mall(id)
  expect_equal(mall$global$test, "test")
  expect_equal(mall$session$test2, "test2")

  app$ignite(block = FALSE, silent = TRUE)
  Sys.sleep(3)
  later::run_now()
  app$extinguish()

  expect_length(mall$session, 0)
})
