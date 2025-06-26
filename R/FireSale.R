#' A FireSale plugin
#'
#' The class encapsulates the firesale functionality into a fiery plugin. You
#' use it by creating and attaching it to a fiery server object.
#'
#' @usage NULL
#' @format NULL
#'
#' @section Initialization:
#' A new 'FireSale'-object is initialized using the \code{new()} method on the
#' generator (shown here with the environment driver):
#'
#' \strong{Usage}
#' \tabular{l}{
#'  \code{datastore <- FireSale$new(storr::driver_environment())}
#' }
#'
#' @section Fiery plugin:
#' This class is mainly intended to be used as a fiery plugin, by attaching it
#' to a fiery server object. It works by providing a `datastore` element (name
#' can be modified with the `arg_name` argument during initialization) in the
#' `arg_list` argument to `request` handlers. The object contains two elements,
#' `global` and `session`. The first contains data shared by all sessions, while
#' the latter is scoped to the current session. Both of these elements are
#' list-like, but in reality are interfaces to the underlying data store
#'
#' @export
#'
#' @examples
#' # Create a datastore object
#' ds <- FireSale$new(storr::driver_environment())
#'
#' @examplesIf requireNamespace("fiery", quietly = TRUE)
#' # Attach it to a fiery server
#' app <- fiery::Fire$new()
#'
#' app$attach(ds)
#'
FireSale <- R6::R6Class(
  "FireSale",
  public = list(
    #' @description Initializes a new FireSale object
    #' @param driver A storr driver to use for the backend
    #' @param arg_name A string giving the name under which the data store
    #' should appear in the `arg_list` argument
    #' @param gc_interval The interval with which the backend should be garbage
    #' collected. The value is indicative and a garbage collection may happen
    #' at longer intervals
    #' @param max_age The maximum age in second an ID can be left unused before
    #' being purged. The value is indicative and a stale ID store may linger
    #' longer than this
    #'
    initialize = function(
      driver,
      arg_name = "datastore",
      gc_interval = 3600,
      max_age = gc_interval
    ) {
      private$STORR <- storr::storr(driver)
      check_string(arg_name)
      private$ARGNAME <- arg_name
      check_number_decimal(
        gc_interval,
        min = 0,
        allow_infinite = FALSE,
        allow_null = TRUE
      )
      private$GCINTERVAL <- gc_interval
      check_number_decimal(
        max_age,
        min = 0,
        allow_infinite = FALSE,
        allow_null = TRUE
      )
      private$MAXAGE <- max_age
      private$GLOBALSTORE <- new_storefront("global", private$STORR)
    },
    #' @description Textual representation of the plugin
    #' @param ... ignored
    format = function(...) {
      driver <- sub("driver_", "", class(private$STORR$driver)[1])
      paste0("<FireSale plugin (", driver, ")>")
    },
    #' @description Create a mall (a collection of storefronts) containing a
    #' global and a session-specific storefront
    #' @param id The session id of the current session
    get_mall = function(id) {
      if (!is.null(private$MAXAGE)) {
        private$STORR$set(id, Sys.time(), namespace = "_id_access")
      }
      new_mall(
        list(
          global = private$GLOBALSTORE,
          session = new_storefront(id, private$STORR)
        )
      )
    },
    #' @description Method for use by `fiery` when attached as a plugin. Should
    #' not be called directly.
    #' @param app The fiery server object
    #' @param ... Ignored
    on_attach = function(app, ...) {
      app$on(
        "before-request",
        function(server, id, request) {
          set_names(list(self$get_mall(id = id)), private$ARGNAME)
        },
        id = "firesale_datastore_attach"
      )
      if (!(is.null(private$GCINTERVAL) && is.null(private$MAXAGE))) {
        app$time(
          {
            private$clean_stale()
            private$run_gc()
          },
          after = min(private$GCINTERVAL, private$MAXAGE),
          loop = TRUE
        )
      }
    }
  ),
  active = list(
    #' @field name The name of the plugin
    name = function() {
      "firesale"
    }
  ),
  private = list(
    STORR = NULL,
    ARGNAME = "datastore",
    GCINTERVAL = NULL,
    MAXAGE = NULL,
    GLOBALSTORE = NULL,

    clean_stale = function() {
      if (!is.null(private$MAXAGE)) {
        all_id <- private$STORR$list("_id_access")
        all_ages <- unlist(private$STORR$mget(all_id, "_id_access"))
        purge <- which(Sys.time() - all_ages > private$MAXAGE)

        for (i in purge) {
          private$STORR$clear(all_id[i])
        }
        private$STORR$del(all_id[purge], "_id_access")
      }
    },
    run_gc = function() {
      if (!is.null(private$GCINTERVAL)) {
        last_gc <- private$STORR$mget(
          "timestamp",
          "_gc_time",
          missing = as.POSIXct(0)
        )[[1]]
        now <- Sys.time()
        if (now - last_gc > private$GCINTERVAL) {
          private$STORR$gc()
          private$STORR$set("timestamp", now, namespace = "_gc_time")
        }
      }
    }
  )
)
