
<!-- README.md is generated from README.Rmd. Please edit that file -->

# firesale

<!-- badges: start -->

[![R-CMD-check](https://github.com/thomasp85/firesale/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/thomasp85/firesale/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/thomasp85/firesale/graph/badge.svg)](https://app.codecov.io/gh/thomasp85/firesale)
<!-- badges: end -->

firesale is a plugin for [fiery](http://fiery.data-imaginist.com/) that
provides a (potentially persistent) data store based on path parameters
and client id.

It builds upon the [storr](https://richfitz.github.io/storr) package and
thus provides a multitude of storage backends to suit your need while
providing the same interface for your server logic.

## Installation

`firesale` is still not available on CRAN. In the meantime you can
install it from gihub using pak

``` r
# install.packages("pak")
pak::pak("thomasp85/firesale")
```

## Example

Using firesale is quite simple. You initialise the plugin and then
attach it to your fiery server:

``` r
library(firesale)

ds <- FireSale$new(storr::driver_environment())

ds
#> <FireSale plugin (environment)>
```

Once created you attach it like any other plugin

``` r
app <- fiery::Fire$new()

app$attach(ds)

app
#> 🔥 A fiery webserver
#> 🔥  💥   💥   💥
#> 🔥           Running on: 127.0.0.1:8080
#> 🔥     Plugins attached: firesale
#> 🔥 Event handlers added
#> 🔥       before-request: 1
```

Now, your request handlers will have access to a `datastore` element in
their `arg_list` argument which will grant you access to the datastore.
The `datastore` will itself contain two elements: `global` and
`session`. The former gives access to a datastore shared by all
sessions, while the latter is scoped to the session of the request being
handled

``` r
app$on("request", function(request, response, arg_list, ...) {
  response$status <- 200L

  # Use `session` to see if this is the first time
  if (!isFALSE(arg_list$datastore$session$first)) {
    # Store number of unique visitors in `global`
    arg_list$datastore$global$count <- (arg_list$datastore$global$count %||% 0) + 1

    response$body <- paste0(
      "This is your first visit\n",
      "You are visiter number ",
      arg_list$datastore$global$count
    )
    arg_list$datastore$session$first <- FALSE
  } else {
    response$body <- "You've been here before"
  }
})
```

As can be seen, the `datastore` and its element are list-like and you
can treat `session` and `global` pretty much how you would a normal list
in terms of getting and setting values.
