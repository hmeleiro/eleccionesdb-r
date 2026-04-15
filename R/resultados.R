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
    params <- list(
        eleccion_id = eleccion_id,
        territorio_id = territorio_id,
        year = year,
        tipo_eleccion = tipo_eleccion,
        tipo_territorio = tipo_territorio,
        codigo_ccaa = codigo_ccaa,
        codigo_provincia = codigo_provincia,
        codigo_municipio = codigo_municipio
    )
    tbl <- edb_paginated_get(
        path = "/v1/resultados/totales-territorio",
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
    params <- list(
        eleccion_id = eleccion_id,
        territorio_id = territorio_id,
        partido_id = partido_id,
        year = year,
        tipo_eleccion = tipo_eleccion,
        tipo_territorio = tipo_territorio,
        codigo_ccaa = codigo_ccaa,
        codigo_provincia = codigo_provincia,
        codigo_municipio = codigo_municipio
    )
    tbl <- edb_paginated_get(
        path = "/v1/resultados/votos-partido",
        params = params,
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

#' List combined results (fully expanded)
#'
#' Returns paginated votes with party (including recode), territory, and
#' election information fully expanded and flattened into a wide tibble.
#' This is the most convenient function for cross-dimensional analysis.
#'
#' When `clean = TRUE` (the default), prefixed columns are renamed to
#' short names and only the most useful subset is returned:
#' `year`, `mes`, `tipo_eleccion`, `tipo_territorio`, `territorio_nombre`,
#' `codigo_ccaa`, `codigo_provincia`, `siglas`, `denominacion`,
#' `partido_recode`, `votos`, `representantes`.
#'
#' Set `clean = FALSE` to get the full flattened tibble with all prefixed
#' columns (`partido_*`, `recode_*`, `territorio_*`, `eleccion_*`).
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
#' @param clean Logical. If `TRUE` (default), renames prefixed columns and
#'   selects only user-friendly columns. If `FALSE`, returns all flattened
#'   columns.
#' @return A tibble. When `clean = TRUE`: `year`, `mes`, `tipo_eleccion`,
#'   `tipo_territorio`, `territorio_nombre`, `codigo_ccaa`,
#'   `codigo_provincia`, `siglas`, `denominacion`, `partido_recode`,
#'   `votos`, `representantes`. When `clean = FALSE`: all flattened columns
#'   with prefixes `partido_*`, `recode_*`, `territorio_*`, `eleccion_*`.
#' @export
#' @examples
#' \dontrun{
#' # Provincial results for general elections in Andalucia (clean)
#' get_resultados(
#'     tipo_eleccion = "G", year = "2019",
#'     tipo_territorio = "provincia",
#'     codigo_ccaa = "01",
#'     all_pages = TRUE
#' )
#'
#' # Full flattened output
#' get_resultados(
#'     tipo_eleccion = "G", year = "2019",
#'     tipo_territorio = "provincia",
#'     clean = FALSE
#' )
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
                           all_pages = FALSE,
                           clean = TRUE,
                           api_key = NULL) {
    #' @param api_key (Opcional) Clave de API para sobrescribir la global solo en esta llamada.
    params <- list(
        eleccion_id = eleccion_id,
        territorio_id = territorio_id,
        partido_id = partido_id,
        year = year,
        tipo_eleccion = tipo_eleccion,
        tipo_territorio = tipo_territorio,
        codigo_ccaa = codigo_ccaa,
        codigo_provincia = codigo_provincia,
        codigo_municipio = codigo_municipio
    )
    tbl <- edb_paginated_get(
        path = "/v1/resultados/combinados",
        params = params,
        limit = limit,
        skip = skip,
        all_pages = all_pages,
        parse_fn = flatten_combinados,
        api_key = api_key
    )
    if (clean) {
        tbl <- clean_combinados_tbl(tbl)
    } else {
        tbl <- sort_result_tbl(tbl)
    }
    tbl
}
