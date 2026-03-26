#' Perform an API request and return parsed JSON
#'
#' Executes an httr2 request, handles HTTP errors (404, 422, others)
#' and network failures with user-friendly cli messages.
#'
#' @param req An httr2 request object.
#' @return Parsed JSON as an R list.
#' @noRd
edb_perform <- function(req) {
    resp <- tryCatch(
        httr2::req_perform(req, error_call = rlang::caller_env()),
        httr2_http_404 = function(cnd) {
            body <- try_parse_body(cnd$resp)
            detail <- body[["detail"]] %||% "Recurso no encontrado"
            cli::cli_abort(
                c("x" = "API error (404): {detail}"),
                call = rlang::caller_env(n = 4)
            )
        },
        httr2_http_422 = function(cnd) {
            body <- try_parse_body(cnd$resp)
            details <- body[["detail"]]
            if (is.list(details)) {
                msgs <- vapply(details, function(d) {
                    loc <- paste(d[["loc"]], collapse = " > ")
                    paste0("[", loc, "] ", d[["msg"]])
                }, character(1))
                cli::cli_abort(
                    c("x" = "Error de validacion (422):", msgs),
                    call = rlang::caller_env(n = 4)
                )
            }
            cli::cli_abort(
                c("x" = "Error de validacion (422)"),
                call = rlang::caller_env(n = 4)
            )
        },
        httr2_http = function(cnd) {
            status <- httr2::resp_status(cnd$resp)
            body <- try_parse_body(cnd$resp)
            detail <- body[["detail"]] %||% httr2::resp_status_desc(cnd$resp)
            cli::cli_abort(
                c("x" = "API error ({status}): {detail}"),
                call = rlang::caller_env(n = 4)
            )
        },
        httr2_failure = function(cnd) {
            cli::cli_abort(
                c(
                    "x" = "No se pudo conectar con la API de EleccionesDB.",
                    "i" = "URL base: {.url {edb_get_base_url()}}",
                    "i" = "Verifica que el servidor esta en ejecucion."
                ),
                parent = cnd,
                call = rlang::caller_env(n = 4)
            )
        }
    )
    httr2::resp_body_json(resp)
}

#' Try to parse HTTP response body as JSON
#' @noRd
try_parse_body <- function(resp) {
    tryCatch(
        httr2::resp_body_json(resp),
        error = function(e) list()
    )
}

#' Build and perform a GET request with query parameters
#'
#' @param path Character. API path.
#' @param ... Named query parameters. `NULL` values are dropped.
#'   Vector values are passed as repeated params (`.multi = "explode"`).
#' @return Parsed JSON as an R list.
#' @noRd
edb_get <- function(path, ...) {
    params <- drop_nulls(list(...))
    req <- edb_base_request(path)
    if (length(params) > 0) {
        req <- httr2::req_url_query(req, !!!params, .multi = "explode")
    }
    edb_perform(req)
}

#' Drop NULL elements from a list
#' @noRd
drop_nulls <- function(x) {
    x[!vapply(x, is.null, logical(1))]
}
