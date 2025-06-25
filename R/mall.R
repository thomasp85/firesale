new_mall <- function(storefronts) {
  structure(
    storefronts,
    class = "firesale_mall"
  )
}
#' @export
print.firesale_mall <- function(x, ...) {
  cat("<firesale mall (", length(x), ")>\n", sep = "")
  for (i in seq_along(x)) {
    name <- names(x)[i]
    fmt <- sub("^.*? : ", "", format(x[[name]]))
    if (i != 1) {
      cat("\n")
    }
    cat("$", name, "\n", sep = "")
    cat(fmt, "\n", sep = "")
  }
}
#' @export
as.list.firesale_mall <- function(x, ...) unclass(x)
#' @export
`[[<-.firesale_mall` <- function(x, i, value) {
  if (!identical(.subset2(x, i), value)) {
    cli::cli_abort("You cannot replace a storefront")
  }
  x
}
#' @export
`$<-.firesale_mall` <- function(x, i, value) {
  `[[<-`(x, i, value)
}
#' @export
`[.firesale_mall` <- function(x, i, ...) {
  cli::cli_abort(c("Not implemented", i = "use `[[]]` or `$` to index a mall"))
}
#' @export
`[<-.firesale_mall` <- function(x, i, value) {
  cli::cli_abort(c("Not implemented", i = "use `[[]]` or `$` to index a mall"))
}
