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
edb_get <- function(path, ..., api_key = NULL) {
    params <- drop_nulls(list(...))
    req <- edb_base_request(path, api_key = api_key)
    if (length(params) > 0) {
        req <- httr2::req_url_query(req, !!!params, .multi = "explode")
    }
    edb_perform(req)
}

#' Build and perform a POST request with a JSON body
#'
#' @param path Character. API path.
#' @param body A named list to serialise as JSON.
#' @return Parsed JSON as an R list.
#' @noRd
edb_post <- function(path, body, api_key = NULL) {
    req <- edb_base_request(path, api_key = api_key)
    req <- httr2::req_method(req, "POST")
    req <- httr2::req_body_json(req, body)
    edb_perform(req)
}

#' Drop NULL elements from a list
#' @noRd
drop_nulls <- function(x) {
    x[!vapply(x, is.null, logical(1))]
}

#' Convert a value to a list, returning NULL unchanged
#'
#' Used when building POST bodies: scalar or vector values are wrapped in
#' `as.list()` so the JSON serialiser emits an array; `NULL` stays `NULL`
#' so it can be removed by `Filter(Negate(is.null), body)`.
#'
#' @param x Any R object.
#' @return `NULL` if `x` is `NULL`; otherwise `as.list(x)`.
#' @noRd
to_json_array <- function(x) if (is.null(x)) NULL else as.list(x)

#' Like `to_json_array()` but also coerces values to character
#'
#' Use for fields that the API schema declares as strings (e.g. `year`,
#' `tipo_eleccion`, `codigo_ccaa`) so that a user-supplied numeric is sent
#' as `"2023"` rather than `2023`.
#'
#' @param x Any R object.
#' @return `NULL` if `x` is `NULL`; otherwise `as.list(as.character(x))`.
#' @noRd
to_json_str_array <- function(x) if (is.null(x)) NULL else as.list(as.character(x))
