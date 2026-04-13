#' Set the EleccionesDB API base URL
#'
#' @param url Character string with the base URL (e.g. `"https://data.hmeleiro.com/"`).
#' @return The previous base URL, invisibly.
#' @export
#' @examples
#' \dontrun{
#' edb_set_base_url("http://my-server:8000")
#' }
edb_set_base_url <- function(url) {
    if (!is.character(url) || length(url) != 1 || nchar(url) == 0) {
        cli::cli_abort("{.arg url} must be a non-empty character string.")
    }
    url <- sub("/+$", "", url)
    old <- .eleccionesdb_env$base_url

    .eleccionesdb_env$base_url <- url
    invisible(old)
}

#' Get the current EleccionesDB API base URL
#'
#' @return Character string with the current base URL.
#' @export
#' @examples
#' edb_get_base_url()
edb_get_base_url <- function() {
    .eleccionesdb_env$base_url
}

#' Build a base httr2 request for the API
#'
#' @param path Character. The API path (e.g. `"/v1/elecciones"`).
#' @return An httr2 request object.
#' @noRd
edb_base_request <- function(path) {
    httr2::request(.eleccionesdb_env$base_url) |>
        httr2::req_url_path_append(path) |>
        httr2::req_headers("Accept" = "application/json") |>
        httr2::req_user_agent("eleccionesdb-r/0.1.0")
}
