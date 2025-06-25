new_storefront <- function(namespace, backend) {
  structure(
    list(),
    namespace = namespace,
    backend = backend,
    class = "firesale_storefront"
  )
}
is_storefront <- function(x) inherits(x, "firesale_storefront")

#' @export
format.firesale_storefront <- function(x, ...) {
  attr(x, "namespace")
}
#' @export
print.firesale_storefront <- function(x, ...) {
  driver <- sub("driver_", "", class(backend(x)$driver)[1])
  cat("<firesale storefront (", driver, ")>\n", sep = "")
  cat(format(x))
}
#' @export
names.firesale_storefront <- function(x) {
  backend(x)$list(ns(x))
}
#' @export
length.firesale_storefront <- function(x) {
  length(names(x))
}
#' @export
as.list.firesale_storefront <- function(x, ...) x[names(x)]
#' @export
`[[.firesale_storefront` <- function(x, i, ...) {
  try_fetch(backend(x)$get(i, ns(x)), KeyError = function(...) NULL)
}
#' @export
`[[<-.firesale_storefront` <- function(x, i, value) {
  backend(x)$set(i, value, ns(x))
  x
}
#' @export
`$.firesale_storefront` <- function(x, i) {
  x[[i]]
}
#' @export
`$<-.firesale_storefront` <- function(x, i, value) {
  `[[<-`(x, i, value)
}
#' @export
`[.firesale_storefront` <- function(x, i, ...) {
  structure(backend(x)$mget(i, ns(x)), names = i, missing = NULL)
}
#' @export
`[<-.firesale_storefront` <- function(x, i, value) {
  backend(x)$mset(i, value, ns(x))
  x
}

# Helpers ----------------------------------------------------------------

backend <- function(x) {
  attr(x, "backend")
}
ns <- function(x) {
  attr(x, "namespace")
}
