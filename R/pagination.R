#' Fetch all pages from a paginated endpoint
#'
#' Automatically loops through pages using skip/limit until all records are
#' retrieved. Shows a progress bar when more than one page is needed.
#'
#' @param path Character. API path.
#' @param params Named list of query parameters (filters). NULL values are dropped.
#' @param max_limit Integer. Page size to use (max 500, the API limit).
#' @param parse_fn Function to post-process each page's tibble (e.g. coerce_dates).
#'   Applied to each page before binding.
#' @return A tibble with all records.
#' @noRd
edb_get_all_pages <- function(path, params = list(), max_limit = 500L,
                              parse_fn = identity, api_key = NULL) {
    params <- drop_nulls(params)

    # Probe request to check total before downloading
    probe_params <- params
    probe_params[["limit"]] <- 1L
    probe_params[["skip"]] <- 0L
    probe_json <- do.call(edb_get, c(list(path = path, api_key = api_key), probe_params))
    total <- probe_json[["total"]] %||% 0L

    if (total > 25000) {
        cli::cli_inform(c(
            "!" = "La petici\u00f3n devuelve {total} registros.",
            "i" = "Considera filtrar por {.arg tipo_territorio}, {.arg tipo_eleccion} u otros par\u00e1metros para reducir el volumen."
        ))
    }

    if (total == 0) {
        return(parse_fn(parse_paginated(probe_json)))
    }

    # Start actual download
    params[["limit"]] <- max_limit
    params[["skip"]] <- 0L
    json <- do.call(edb_get, c(list(path = path, api_key = api_key), params))

    first_page <- parse_fn(parse_paginated(json))
    collected <- list(first_page)
    fetched <- nrow(first_page)

    if (fetched >= total) {
        tbl <- first_page
        attr(tbl, "edb_total") <- total
        return(tbl)
    }

    # Multiple pages needed
    n_pages <- ceiling(total / max_limit)
    cli::cli_progress_bar(
        "Descargando registros",
        total = total,
        clear = FALSE
    )
    cli::cli_progress_update(set = fetched)

    while (fetched < total) {
        params[["skip"]] <- fetched
        json <- do.call(edb_get, c(list(path = path, api_key = api_key), params))
        page <- parse_fn(parse_paginated(json))
        if (nrow(page) == 0) break
        collected <- c(collected, list(page))
        fetched <- fetched + nrow(page)
        cli::cli_progress_update(set = fetched)
    }

    cli::cli_progress_done()

    tbl <- vctrs::vec_rbind(!!!collected)
    attr(tbl, "edb_total") <- total
    tbl
}

#' Standard paginated GET with optional all_pages
#'
#' This is the main entry point used by all paginated endpoint functions.
#' When `all_pages = TRUE`, it auto-fetches everything.
#' When `all_pages = FALSE`, it makes a single request with the given skip/limit.
#'
#' @param path Character. API path.
#' @param params Named list of query parameters (filters).
#' @param limit Integer. Records per page (default 50, max 500).
#' @param skip Integer. Records to skip (default 0).
#' @param all_pages Logical. If TRUE, fetch all pages automatically.
#' @param parse_fn Function to post-process each page's tibble.
#' @return A tibble.
#' @noRd
edb_paginated_get <- function(path, params = list(), limit = 50L, skip = 0L,
                              all_pages = FALSE, parse_fn = identity, api_key = NULL) {
    if (all_pages) {
        return(edb_get_all_pages(path, params, parse_fn = parse_fn, api_key = api_key))
    }

    params <- drop_nulls(params)
    params[["limit"]] <- limit
    params[["skip"]] <- skip
    json <- do.call(edb_get, c(list(path = path, api_key = api_key), params))
    parse_fn(parse_paginated(json))
}
