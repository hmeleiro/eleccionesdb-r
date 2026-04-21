#' List territorial totals for an election
#'
#' Returns paginated territorial totals (census, participation, blank/null
#' votes, etc.) for a specific election, with optional territorial filters.
#'
#' @param eleccion_id Integer. The election ID (required).
#' @param tipo_territorio Character vector. Filter by territory type.
#'   Valid values: `"ccaa"`, `"provincia"`, `"municipio"`, `"distrito"`,
#'   `"seccion"`, `"circunscripcion"`, `"cera"`. Optional.
#' @param codigo_ccaa Character vector. Filter by autonomous community INE
#'   code(s) (e.g. `"01"`, `"13"`). Optional.
#' @param codigo_provincia Character vector. Filter by province INE code(s)
#'   (e.g. `"28"`, `"08"`). Optional.
#' @param codigo_municipio Character vector. Filter by municipality INE
#'   code(s). Optional.
#' @param ... Arguments after `...` must be named.
#' @param territorio_id Integer vector. Filter by territory ID(s). Optional.
#' @param limit Integer. Maximum records per page (1-500, default 50).
#' @param skip Integer. Records to skip (default 0).
#' @param all_pages Logical. If `TRUE`, fetches all pages. Default `FALSE`.
#' @param denormalize Logical. If `TRUE`, adds descriptive columns next to
#'   ID columns: `eleccion_descripcion` (after `eleccion_id`) and
#'   `territorio_nombre` (after `territorio_id`). Requires additional API
#'   calls. Default `FALSE`.
#' @param clean Logical. If `TRUE`, removes ID and slug columns from the
#'   result. Defaults to the value of `denormalize`.
#' @return A tibble with columns: `id`, `eleccion_id`, `territorio_id`,
#'   `censo_ine`, `participacion_1`, `participacion_2`, `participacion_3`,
#'   `votos_validos`, `abstenciones`, `votos_blancos`, `votos_nulos`,
#'   `nrepresentantes`. When `denormalize = TRUE`, additional columns
#'   `eleccion_descripcion` and `territorio_nombre` are inserted after
#'   their corresponding ID columns. When `clean = TRUE`, ID and slug
#'   columns are removed.
#' @export
#' @examples
#' \dontrun{
#' # Totals for a general election, by province
#' get_totales_territorio_eleccion(208, tipo_territorio = "provincia")
#'
#' # All totals for an election
#' get_totales_territorio_eleccion(208, all_pages = TRUE)
#'
#' # With denormalized names (clean by default)
#' get_totales_territorio_eleccion(208,
#'     tipo_territorio = "provincia",
#'     denormalize = TRUE
#' )
#' }
get_totales_territorio_eleccion <- function(eleccion_id,
                                            tipo_territorio = NULL,
                                            codigo_ccaa = NULL,
                                            codigo_provincia = NULL,
                                            codigo_municipio = NULL,
                                            ...,
                                            territorio_id = NULL,
                                            limit = 50L, skip = 0L,
                                            all_pages = FALSE,
                                            denormalize = FALSE,
                                            clean = denormalize,
                                            api_key = NULL) {
    #' @param api_key (Opcional) Clave de API para sobrescribir la global solo en esta llamada.
    params <- list(
        territorio_id = territorio_id,
        tipo_territorio = tipo_territorio,
        codigo_ccaa = codigo_ccaa,
        codigo_provincia = codigo_provincia,
        codigo_municipio = codigo_municipio
    )
    tbl <- edb_paginated_get(
        path = paste0("/v1/elecciones/", eleccion_id, "/totales-territorio"),
        params = params,
        limit = limit,
        skip = skip,
        all_pages = all_pages,
        api_key = api_key
    )
    if (denormalize) {
        tbl <- denormalize_tbl(tbl)
    }
    if (clean) {
        tbl <- clean_result_tbl(tbl)
    }
    sort_result_tbl(tbl)
}

#' Get complete result for an election and territory
#'
#' Returns the territorial summary and per-party vote breakdown for a
#' specific election-territory combination. This is a composite endpoint
#' that returns a named list.
#'
#' Party information is flattened into the votes tibble with prefixed
#' columns (`partido_id`, `partido_siglas`, `partido_denominacion`,
#' `partido_partido_recode_id`).
#'
#' @param eleccion_id Integer. The election ID.
#' @param territorio_id Integer. The territory ID.
#' @param ... Arguments after `...` must be named.
#' @param denormalize Logical. If `TRUE`, adds descriptive columns next to
#'   ID columns: `eleccion_descripcion`, `territorio_nombre` (in both
#'   `totales_territorio` and `votos_partido`), and `partido_nombre`
#'   (in `votos_partido`). Requires additional API calls. Default `FALSE`.
#' @param use_recode Logical. If `TRUE` and `denormalize = TRUE`, the
#'   `partido_nombre` column uses the recode group name (`agrupacion`)
#'   instead of the party abbreviation (`siglas`). Falls back to `siglas`
#'   when the party has no recode. Default `FALSE`.
#' @param clean Logical. If `TRUE`, removes ID and slug columns from both
#'   sub-tibbles. Defaults to the value of `denormalize`.
#' @return A named list with two elements:
#'   \describe{
#'     \item{`totales_territorio`}{A 1-row tibble with summary fields: `id`,
#'       `eleccion_id`, `territorio_id`, `censo_ine`, `participacion_1`,
#'       `participacion_2`, `participacion_3`, `votos_validos`,
#'       `abstenciones`, `votos_blancos`, `votos_nulos`, `nrepresentantes`.}
#'     \item{`votos_partido`}{A tibble of per-party votes, sorted by votes
#'       descending. Columns: `id`, `eleccion_id`, `territorio_id`,
#'       `partido_id`, `votos`, `representantes`, `partido_id`,
#'       `partido_siglas`, `partido_denominacion`,
#'       `partido_partido_recode_id`.}
#'   }
#'   When `denormalize = TRUE`, additional columns `eleccion_descripcion`,
#'   `territorio_nombre`, and `partido_nombre` (in `votos_partido`) are inserted.
#'   When `clean = TRUE`, ID and slug columns are removed.
#' @export
#' @examples
#' \dontrun{
#' result <- get_resultado_completo(208, 20)
#' result$totales_territorio
#' result$votos_partido
#'
#' # With recode-based party names
#' result <- get_resultado_completo(208, 20,
#'     denormalize = TRUE, use_recode = TRUE
#' )
#' }
get_resultado_completo <- function(eleccion_id, territorio_id, ...,
                                   denormalize = FALSE,
                                   use_recode = FALSE,
                                   clean = denormalize,
                                   api_key = NULL) {
    #' @param api_key (Opcional) Clave de API para sobrescribir la global solo en esta llamada.
    path <- paste0(
        "/v1/elecciones/", eleccion_id, "/totales-territorio/",
        territorio_id
    )
    json <- edb_get(path, api_key = api_key)

    totales_data <- json[["totales_territorio"]]
    votos_data <- json[["votos_partido"]] %||% list()

    totales_tbl <- if (!is.null(totales_data)) {
        parse_single(totales_data)
    } else {
        tibble::tibble()
    }

    votos_tbl <- safe_tibble(votos_data)
    votos_tbl <- flatten_partido(votos_tbl)

    if (denormalize) {
        totales_tbl <- denormalize_tbl(totales_tbl)
        votos_tbl <- denormalize_tbl(votos_tbl, use_recode = use_recode)
    }

    if (clean) {
        totales_tbl <- clean_result_tbl(totales_tbl)
        votos_tbl <- clean_result_tbl(votos_tbl)
    }

    list(
        totales_territorio = sort_result_tbl(totales_tbl),
        votos_partido = sort_result_tbl(votos_tbl)
    )
}

#' List territorial totals (cross-election)
#'
#' Returns paginated territorial totals across elections, with
#' flexible filters. Unlike [get_totales_territorio_eleccion()], this can
#' query across multiple elections.
#'
#' @param year Character vector. Filter by year(s). Optional.
#' @param tipo_eleccion Character vector. Filter by election type code(s).
#'   Valid values: `"A"` (Autonomicas), `"E"` (Europeas), `"G"` (Congreso),
#'   `"L"` (Locales), `"S"` (Senado). Optional.
#' @param tipo_territorio Character vector. Filter by territory type(s).
#'   Valid values: `"ccaa"`, `"provincia"`, `"municipio"`, `"distrito"`,
#'   `"seccion"`, `"circunscripcion"`, `"cera"`. Optional.
#' @param codigo_ccaa Character vector. Filter by autonomous community INE
#'   code(s) (e.g. `"01"`, `"13"`). Optional.
#' @param codigo_provincia Character vector. Filter by province INE code(s)
#'   (e.g. `"28"`, `"08"`). Optional.
#' @param codigo_municipio Character vector. Filter by municipality INE
#'   code(s). Optional.
#' @param ... Arguments after `...` must be named.
#' @param eleccion_id Integer vector. Filter by election ID(s). Optional.
#' @param territorio_id Integer vector. Filter by territory ID(s). Optional.
#' @param limit Integer. Maximum records per page (1-500, default 50).
#' @param skip Integer. Records to skip (default 0).
#' @param all_pages Logical. If `TRUE`, fetches all pages. Default `FALSE`.
#' @param denormalize Logical. If `TRUE`, adds descriptive columns next to
#'   ID columns: `eleccion_descripcion` (after `eleccion_id`) and
#'   `territorio_nombre` (after `territorio_id`). Requires additional API
#'   calls. Default `FALSE`.
#' @param clean Logical. If `TRUE`, removes ID and slug columns from the
#'   result. Defaults to the value of `denormalize`.
#' @return A tibble with columns: `id`, `eleccion_id`, `territorio_id`,
#'   `censo_ine`, `participacion_1`, `participacion_2`, `participacion_3`,
#'   `votos_validos`, `abstenciones`, `votos_blancos`, `votos_nulos`,
#'   `nrepresentantes`. When `denormalize = TRUE`, additional columns
#'   `eleccion_descripcion` and `territorio_nombre` are inserted after
#'   their corresponding ID columns. When `clean = TRUE`, ID and slug
#'   columns are removed.
#' @export
#' @examples
#' \dontrun{
#' # Provincial totals for general elections in 2019
#' get_totales_territorio(
#'     year = "2019", tipo_eleccion = "G",
#'     tipo_territorio = "provincia"
#' )
#'
#' # With denormalized names (clean by default)
#' get_totales_territorio(
#'     year = "2019", tipo_eleccion = "G",
#'     tipo_territorio = "provincia",
#'     denormalize = TRUE
#' )
#' }
get_totales_territorio <- function(year = NULL, tipo_eleccion = NULL,
                                   tipo_territorio = NULL, codigo_ccaa = NULL,
                                   codigo_provincia = NULL,
                                   codigo_municipio = NULL,
                                   ...,
                                   eleccion_id = NULL, territorio_id = NULL,
                                   limit = 50L, skip = 0L, all_pages = FALSE,
                                   denormalize = FALSE,
                                   clean = denormalize,
                                   api_key = NULL) {
    #' @param api_key (Opcional) Clave de API para sobrescribir la global solo en esta llamada.
    filters <- Filter(Negate(is.null), list(
        eleccion_id    = to_json_array(eleccion_id),
        territorio_id  = to_json_array(territorio_id),
        year           = to_json_str_array(year),
        tipo_eleccion  = to_json_str_array(tipo_eleccion),
        tipo_territorio = to_json_str_array(tipo_territorio),
        codigo_ccaa    = to_json_str_array(codigo_ccaa),
        codigo_provincia = to_json_str_array(codigo_provincia),
        codigo_municipio = to_json_str_array(codigo_municipio)
    ))
    tbl <- edb_paginated_post(
        path = "/v1/resultados/totales-territorio",
        filters = filters,
        limit = limit,
        skip = skip,
        all_pages = all_pages,
        api_key = api_key
    )
    if (denormalize) {
        tbl <- denormalize_tbl(tbl)
    }
    if (clean) {
        tbl <- clean_result_tbl(tbl)
    }
    sort_result_tbl(tbl)
}

#' List per-party votes (cross-election)
#'
#' Returns paginated per-party vote records with flexible filters.
#'
#' @param year Character vector. Filter by year(s). Optional.
#' @param tipo_eleccion Character vector. Filter by election type code(s).
#'   Valid values: `"A"` (Autonomicas), `"E"` (Europeas), `"G"` (Congreso),
#'   `"L"` (Locales), `"S"` (Senado). Optional.
#' @param tipo_territorio Character vector. Filter by territory type(s).
#'   Valid values: `"ccaa"`, `"provincia"`, `"municipio"`, `"distrito"`,
#'   `"seccion"`, `"circunscripcion"`, `"cera"`. Optional.
#' @param codigo_ccaa Character vector. Filter by autonomous community INE
#'   code(s) (e.g. `"01"`, `"13"`). Optional.
#' @param codigo_provincia Character vector. Filter by province INE code(s)
#'   (e.g. `"28"`, `"08"`). Optional.
#' @param codigo_municipio Character vector. Filter by municipality INE
#'   code(s). Optional.
#' @param ... Arguments after `...` must be named.
#' @param eleccion_id Integer vector. Filter by election ID(s). Optional.
#' @param territorio_id Integer vector. Filter by territory ID(s). Optional.
#' @param partido_id Integer vector. Filter by party ID(s). Optional.
#' @param limit Integer. Maximum records per page (1-500, default 50).
#' @param skip Integer. Records to skip (default 0).
#' @param all_pages Logical. If `TRUE`, fetches all pages. Default `FALSE`.
#' @param denormalize Logical. If `TRUE`, adds descriptive columns next to
#'   ID columns: `eleccion_descripcion` (after `eleccion_id`),
#'   `territorio_nombre` (after `territorio_id`), and `partido_nombre`
#'   (after `partido_id`). Requires additional API calls. Default `FALSE`.
#' @param use_recode Logical. If `TRUE` and `denormalize = TRUE`, the
#'   `partido_nombre` column uses the recode group name (`agrupacion`)
#'   instead of the party abbreviation (`siglas`). Falls back to `siglas`
#'   when the party has no recode. Default `FALSE`.
#' @param clean Logical. If `TRUE`, removes ID and slug columns from the
#'   result. Defaults to the value of `denormalize`.
#' @return A tibble with columns: `id`, `eleccion_id`, `territorio_id`,
#'   `partido_id`, `votos`, `representantes`. When `denormalize = TRUE`,
#'   additional columns `eleccion_descripcion`, `territorio_nombre`, and
#'   `partido_nombre` are inserted after their corresponding ID columns.
#'   When `clean = TRUE`, ID and slug columns are removed.
#' @export
#' @examples
#' \dontrun{
#' # Votes in general elections of 2019
#' get_votos_partido(
#'     year = "2019", tipo_eleccion = "G",
#'     tipo_territorio = "provincia"
#' )
#'
#' # With denormalized names using recode grouping
#' get_votos_partido(
#'     year = "2019", tipo_eleccion = "G",
#'     tipo_territorio = "provincia",
#'     denormalize = TRUE, use_recode = TRUE, all_pages = TRUE
#' )
#' }
get_votos_partido <- function(year = NULL, tipo_eleccion = NULL,
                              tipo_territorio = NULL, codigo_ccaa = NULL,
                              codigo_provincia = NULL,
                              codigo_municipio = NULL,
                              ...,
                              eleccion_id = NULL, territorio_id = NULL,
                              partido_id = NULL,
                              limit = 50L, skip = 0L, all_pages = FALSE,
                              denormalize = FALSE, use_recode = FALSE,
                              clean = denormalize,
                              api_key = NULL) {
    #' @param api_key (Opcional) Clave de API para sobrescribir la global solo en esta llamada.
    filters <- Filter(Negate(is.null), list(
        eleccion_id    = to_json_array(eleccion_id),
        territorio_id  = to_json_array(territorio_id),
        partido_id     = to_json_array(partido_id),
        year           = to_json_str_array(year),
        tipo_eleccion  = to_json_str_array(tipo_eleccion),
        tipo_territorio = to_json_str_array(tipo_territorio),
        codigo_ccaa    = to_json_str_array(codigo_ccaa),
        codigo_provincia = to_json_str_array(codigo_provincia),
        codigo_municipio = to_json_str_array(codigo_municipio)
    ))
    tbl <- edb_paginated_post(
        path = "/v1/resultados/votos-partido",
        filters = filters,
        limit = limit,
        skip = skip,
        all_pages = all_pages,
        api_key = api_key
    )
    if (denormalize) {
        tbl <- denormalize_tbl(tbl, use_recode = use_recode)
    }
    if (clean) {
        tbl <- clean_result_tbl(tbl)
    }
    sort_result_tbl(tbl)
}

#' List combined results — main analysis function
#'
#' `get_resultados()` is the primary function of the package for analytical
#' use. It returns a wide, ready-to-analyse tibble that combines per-party
#' votes with territorial summary data (census, turnout, blank/null votes)
#' and election metadata, all joined internally so no manual merging is
#' needed.
#'
#' Two API calls are made internally: one to `/v1/resultados/combinados`
#' (votes + party + territory + election, fully expanded) and one to
#' `/v1/resultados/totales-territorio` (census and turnout totals). The
#' results are joined by `(eleccion_id, territorio_id)` before being
#' returned.
#'
#' When `clean = TRUE` (the default), prefixed columns are renamed to short,
#' user-friendly names and only the most useful columns are returned.
#' Set `clean = FALSE` to get all flattened columns with their original
#' prefixes (`partido_*`, `recode_*`, `territorio_*`, `eleccion_*`) plus
#' the flat summary columns.
#'
#' @param year Character vector. Filter by year(s). Optional.
#' @param tipo_eleccion Character vector. Filter by election type code(s).
#'   Valid values: `"A"` (Autonomicas), `"E"` (Europeas), `"G"` (Congreso),
#'   `"L"` (Locales), `"S"` (Senado). Optional.
#' @param tipo_territorio Character vector. Filter by territory type(s).
#'   Valid values: `"ccaa"`, `"provincia"`, `"municipio"`, `"distrito"`,
#'   `"seccion"`, `"circunscripcion"`, `"cera"`. Optional.
#' @param codigo_ccaa Character vector. Filter by autonomous community INE
#'   code(s) (e.g. `"01"`, `"13"`). Optional.
#' @param codigo_provincia Character vector. Filter by province INE code(s)
#'   (e.g. `"28"`, `"08"`). Optional.
#' @param codigo_municipio Character vector. Filter by municipality INE
#'   code(s). Optional.
#' @param ... Arguments after `...` must be named.
#' @param eleccion_id Integer vector. Filter by election ID(s). Optional.
#' @param territorio_id Integer vector. Filter by territory ID(s). Optional.
#' @param partido_id Integer vector. Filter by party ID(s). Optional.
#' @param limit Integer. Maximum records per page (1-500, default 50).
#' @param skip Integer. Records to skip (default 0).
#' @param all_pages Logical. If `TRUE`, fetches all pages automatically.
#'   Default `TRUE`.
#' @param clean Logical. If `TRUE` (default), renames prefixed columns to
#'   short names and selects only user-friendly columns. If `FALSE`, returns
#'   all flattened columns.
#' @param api_key Character. Optional API key to override the global setting
#'   for this call only.
#' @return A tibble. When `clean = TRUE`:
#'   `year`, `mes`, `tipo_eleccion`, `tipo_territorio`, `territorio_nombre`,
#'   `codigo_ccaa`, `codigo_provincia`, `codigo_municipio`, `codigo_distrito`,
#'   `codigo_seccion`, `censo_ine`, `votos_validos`, `abstenciones`,
#'   `votos_blancos`, `votos_nulos`, `participacion_1`, `participacion_2`,
#'   `participacion_3`, `siglas`, `denominacion`, `partido_recode`,
#'   `partido_agrupacion`, `votos`, `representantes`, `nrepresentantes`.
#'
#'   When `clean = FALSE`: all flattened columns with prefixes
#'   `partido_*`, `recode_*`, `territorio_*`, `eleccion_*`, plus the flat
#'   summary columns (`censo_ine`, `votos_validos`, `abstenciones`,
#'   `votos_blancos`, `votos_nulos`, `participacion_1`, `participacion_2`,
#'   `participacion_3`, `nrepresentantes`).
#' @export
#' @examples
#' \dontrun{
#' # Results by province for Andalucia in the 2019 general election
#' get_resultados(
#'     tipo_eleccion = "G", year = "2019",
#'     tipo_territorio = "provincia",
#'     codigo_ccaa = "01",
#'     all_pages = TRUE
#' )
#'
#' # Provincial results for all general elections (all pages)
#' get_resultados(tipo_eleccion = "G", tipo_territorio = "provincia",
#'                all_pages = TRUE)
#'
#' # Filter afterwards with dplyr
#' library(dplyr)
#' get_resultados(tipo_eleccion = "G", year = "2019",
#'                tipo_territorio = "provincia", all_pages = TRUE) |>
#'     filter(siglas == "PSOE") |>
#'     select(territorio_nombre, votos, representantes,
#'            censo_ine, votos_validos)
#'
#' # Full flattened output (no renaming)
#' get_resultados(tipo_eleccion = "G", year = "2019",
#'                tipo_territorio = "provincia",
#'                clean = FALSE)
#' }
get_resultados <- function(year = NULL, tipo_eleccion = NULL,
                           tipo_territorio = NULL,
                           codigo_ccaa = NULL,
                           codigo_provincia = NULL,
                           codigo_municipio = NULL,
                           ...,
                           eleccion_id = NULL, territorio_id = NULL,
                           partido_id = NULL,
                           limit = 50L, skip = 0L,
                           all_pages = TRUE,
                           clean = TRUE,
                           api_key = NULL) {
    filters <- Filter(Negate(is.null), list(
        eleccion_id    = to_json_array(eleccion_id),
        territorio_id  = to_json_array(territorio_id),
        partido_id     = to_json_array(partido_id),
        year           = to_json_str_array(year),
        tipo_eleccion  = to_json_str_array(tipo_eleccion),
        tipo_territorio = to_json_str_array(tipo_territorio),
        codigo_ccaa    = to_json_str_array(codigo_ccaa),
        codigo_provincia = to_json_str_array(codigo_provincia),
        codigo_municipio = to_json_str_array(codigo_municipio)
    ))
    tbl <- edb_paginated_post(
        path = "/v1/resultados/combinados",
        filters = filters,
        limit = limit,
        skip = skip,
        all_pages = all_pages,
        parse_fn = flatten_combinados,
        api_key = api_key
    )
    tbl <- enrich_with_resumen(tbl, api_key = api_key)
    if (clean) {
        tbl <- clean_combinados_tbl(tbl)
    } else {
        tbl <- sort_result_tbl(tbl)
    }
    tbl
}

#' Results by autonomous community
#'
#' A convenience wrapper around [get_resultados()] that pre-sets
#' `tipo_territorio = "ccaa"`. All other parameters are passed through
#' unchanged. See [get_resultados()] for the full parameter reference and
#' details on the returned tibble.
#'
#' @param ... Arguments passed to [get_resultados()]. The `tipo_territorio`
#'   parameter is fixed to `"ccaa"` and cannot be overridden.
#' @return A tibble as returned by [get_resultados()] filtered to
#'   `tipo_territorio = "ccaa"`.
#' @export
#' @examples
#' \dontrun{
#' # CCAA-level results for general elections in 2019
#' get_ccaa(tipo_eleccion = "G", year = "2019", all_pages = TRUE)
#'
#' # Use dplyr to compare turnout across CCAA
#' library(dplyr)
#' get_ccaa(tipo_eleccion = "G", year = "2019", all_pages = TRUE) |>
#'     distinct(territorio_nombre, censo_ine, votos_validos) |>
#'     mutate(participacion = votos_validos / censo_ine)
#' }
get_ccaa <- function(...) {
    args <- list(...)
    args[["tipo_territorio"]] <- "ccaa"
    do.call(get_resultados, args)
}

#' Results by province
#'
#' A convenience wrapper around [get_resultados()] that pre-sets
#' `tipo_territorio = "provincia"`. All other parameters are passed through
#' unchanged. See [get_resultados()] for the full parameter reference and
#' details on the returned tibble.
#'
#' @param ... Arguments passed to [get_resultados()]. The `tipo_territorio`
#'   parameter is fixed to `"provincia"` and cannot be overridden.
#' @return A tibble as returned by [get_resultados()] filtered to
#'   `tipo_territorio = "provincia"`.
#' @export
#' @examples
#' \dontrun{
#' # Provincial results for general elections in Andalucia
#' get_provincias(tipo_eleccion = "G", year = "2019",
#'               codigo_ccaa = "01", all_pages = TRUE)
#'
#' # Compare PSOE votes across all provinces in 2019
#' library(dplyr)
#' get_provincias(tipo_eleccion = "G", year = "2019", all_pages = TRUE) |>
#'     filter(siglas == "PSOE") |>
#'     arrange(desc(votos))
#' }
get_provincias <- function(...) {
    args <- list(...)
    args[["tipo_territorio"]] <- "provincia"
    do.call(get_resultados, args)
}

#' Results by municipality
#'
#' A convenience wrapper around [get_resultados()] that pre-sets
#' `tipo_territorio = "municipio"`. All other parameters are passed through
#' unchanged. See [get_resultados()] for the full parameter reference and
#' details on the returned tibble.
#'
#' @param ... Arguments passed to [get_resultados()]. The `tipo_territorio`
#'   parameter is fixed to `"municipio"` and cannot be overridden.
#' @return A tibble as returned by [get_resultados()] filtered to
#'   `tipo_territorio = "municipio"`.
#' @export
#' @examples
#' \dontrun{
#' # Municipal results in a province (Almeria = "04")
#' get_municipios(tipo_eleccion = "G", year = "2019",
#'                codigo_provincia = "04", all_pages = TRUE)
#' }
get_municipios <- function(...) {
    args <- list(...)
    args[["tipo_territorio"]] <- "municipio"
    do.call(get_resultados, args)
}

#' Results by census section
#'
#' A convenience wrapper around [get_resultados()] that pre-sets
#' `tipo_territorio = "seccion"`. All other parameters are passed through
#' unchanged. See [get_resultados()] for the full parameter reference and
#' details on the returned tibble.
#'
#' Note: section-level data can be very large. Always use filters
#' (`codigo_provincia`, `codigo_municipio`, etc.) or `all_pages = FALSE`
#' to limit the response size.
#'
#' @param ... Arguments passed to [get_resultados()]. The `tipo_territorio`
#'   parameter is fixed to `"seccion"` and cannot be overridden.
#' @return A tibble as returned by [get_resultados()] filtered to
#'   `tipo_territorio = "seccion"`.
#' @export
#' @examples
#' \dontrun{
#' # Section-level results for a municipality
#' get_secciones(tipo_eleccion = "G", year = "2019",
#'               codigo_municipio = "028079", all_pages = TRUE)
#' }
get_secciones <- function(...) {
    args <- list(...)
    args[["tipo_territorio"]] <- "seccion"
    do.call(get_resultados, args)
}

#' @describeIn get_provincias Retrocompatibility alias for [get_provincias()].
#'   Maintained for backwards compatibility. Prefer `get_provincias()` in new
#'   code.
#' @export
getProvincias <- get_provincias

#' @describeIn get_municipios Retrocompatibility alias for [get_municipios()].
#'   Maintained for backwards compatibility. Prefer `get_municipios()` in new
#'   code.
#' @export
getMunicipios <- get_municipios

#' @describeIn get_secciones Retrocompatibility alias for [get_secciones()].
#'   Maintained for backwards compatibility. Prefer `get_secciones()` in new
#'   code.
#' @export
getSecciones <- get_secciones
