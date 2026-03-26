#' Check API health status
#'
#' Queries the `/health` endpoint and returns the status of the API
#' and its database connection.
#'
#' @return A 1-row tibble with columns `status`, `environment`, `database`.
#' @export
#' @examples
#' \dontrun{
#' get_health()
#' }
get_health <- function() {
    json <- edb_get("/health")
    parse_single(json)
}
