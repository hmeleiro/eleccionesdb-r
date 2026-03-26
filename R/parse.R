#' Parse a paginated API response into a tibble
#'
#' Extracts `$data` from the paginated envelope and converts to tibble.
#' Attaches `"edb_total"` attribute with the total record count.
#'
#' @param json Parsed JSON list with `total`, `skip`, `limit`, `data`.
#' @return A tibble. Empty tibble (0 rows) if `data` is empty.
#' @noRd
parse_paginated <- function(json) {
    data <- json[["data"]] %||% list()
    tbl <- safe_tibble(data)
    attr(tbl, "edb_total") <- json[["total"]] %||% 0L
    attr(tbl, "edb_skip") <- json[["skip"]] %||% 0L
    attr(tbl, "edb_limit") <- json[["limit"]] %||% 50L
    tbl
}

#' Parse a single-object API response into a 1-row tibble
#'
#' @param json Parsed JSON list (a single record).
#' @return A 1-row tibble.
#' @noRd
parse_single <- function(json) {
    safe_tibble(list(json))
}

#' Parse a direct array (non-paginated) API response into a tibble
#'
#' @param json Parsed JSON list (an array of objects).
#' @return A tibble.
#' @noRd
parse_array <- function(json) {
    safe_tibble(json)
}

#' Convert a list of named lists to a tibble, handling NULLs safely
#'
#' Each element of `lst` is a named list (one row). NULL values are replaced
#' with NA of the appropriate type so columns don't become heterogeneous.
#'
#' @param lst A list of named lists.
#' @return A tibble.
#' @noRd
safe_tibble <- function(lst) {
    if (length(lst) == 0) {
        return(tibble::tibble())
    }

    # Collect all field names across all records
    all_names <- unique(unlist(lapply(lst, names)))

    cols <- lapply(all_names, function(nm) {
        vals <- lapply(lst, function(row) {
            v <- row[[nm]]
            if (is.null(v)) NA else v
        })

        # If any value is a list/named-list (nested object), keep as list-column
        is_nested <- vapply(vals, function(v) {
            is.list(v) && !is.null(v)
        }, logical(1))

        if (any(is_nested)) {
            # Ensure all entries are lists (replace NA with NULL-in-list)
            return(vals)
        }

        # Attempt to simplify to atomic vector
        tryCatch(
            unlist(vals),
            error = function(e) vals
        )
    })

    names(cols) <- all_names
    tibble::as_tibble(cols)
}

#' Flatten a nested object column into prefixed columns
#'
#' Takes a tibble with a list-column containing named lists (or NULLs/NAs)
#' and expands it into multiple columns with a prefix.
#'
#' @param tbl A tibble.
#' @param col Character. Name of the list-column to flatten.
#' @param prefix Character. Prefix for the new column names (e.g. `"recode"`
#'   produces `recode_id`, `recode_agrupacion`, etc.).
#' @param drop Logical. Whether to remove the original list-column. Default TRUE.
#' @return A tibble with the nested column replaced by prefixed columns.
#' @noRd
flatten_nested <- function(tbl, col, prefix, drop = TRUE) {
    if (!col %in% names(tbl)) {
        return(tbl)
    }

    nested_col <- tbl[[col]]

    # Collect all field names from non-NULL entries
    all_names <- unique(unlist(lapply(nested_col, function(x) {
        if (is.list(x) && !is.null(x)) names(x) else character(0)
    })))

    if (length(all_names) == 0) {
        # All entries are NULL/NA — add NA columns
        if (drop) {
            tbl[[col]] <- NULL
        }
        return(tbl)
    }

    for (nm in all_names) {
        new_name <- paste0(prefix, "_", nm)
        tbl[[new_name]] <- vapply(nested_col, function(x) {
            if (is.list(x) && !is.null(x)) {
                v <- x[[nm]]
                if (is.null(v)) NA_character_ else as.character(v)
            } else {
                NA_character_
            }
        }, character(1))
    }

    if (drop) {
        tbl[[col]] <- NULL
    }
    tbl
}

#' Flatten nested objects in a combinados-style response
#'
#' Flattens `partido` (with nested `recode`), `territorio`, and `eleccion`
#' into prefixed columns.
#'
#' @param tbl A tibble from a combinados endpoint.
#' @return A tibble with all nested objects flattened.
#' @noRd
flatten_combinados <- function(tbl) {
    if (nrow(tbl) == 0) {
        return(tbl)
    }

    # First flatten partido, which itself contains recode

    if ("partido" %in% names(tbl)) {
        partido_col <- tbl[["partido"]]

        # Extract recode from inside partido
        all_partido_names <- unique(unlist(lapply(partido_col, function(x) {
            if (is.list(x)) setdiff(names(x), "recode") else character(0)
        })))

        for (nm in all_partido_names) {
            new_name <- paste0("partido_", nm)
            vals <- lapply(partido_col, function(x) {
                if (is.list(x)) {
                    v <- x[[nm]]
                    if (is.null(v)) NA else v
                } else {
                    NA
                }
            })
            tbl[[new_name]] <- unlist(vals)
        }

        # Now flatten recode from partido
        recode_vals <- lapply(partido_col, function(x) {
            if (is.list(x)) x[["recode"]] else NULL
        })
        recode_names <- unique(unlist(lapply(recode_vals, function(x) {
            if (is.list(x)) names(x) else character(0)
        })))
        for (nm in recode_names) {
            new_name <- paste0("recode_", nm)
            tbl[[new_name]] <- vapply(recode_vals, function(x) {
                if (is.list(x)) {
                    v <- x[[nm]]
                    if (is.null(v)) NA_character_ else as.character(v)
                } else {
                    NA_character_
                }
            }, character(1))
        }

        tbl[["partido"]] <- NULL
    }

    # Flatten territorio
    tbl <- flatten_nested(tbl, "territorio", "territorio")

    # Flatten eleccion
    tbl <- flatten_nested(tbl, "eleccion", "eleccion")

    tbl
}

#' Flatten partido (with recode) in voto-con-partido responses
#'
#' @param tbl A tibble with a `partido` list-column.
#' @return A tibble with partido fields as prefixed columns.
#' @noRd
flatten_partido <- function(tbl) {
    if (nrow(tbl) == 0 || !"partido" %in% names(tbl)) {
        return(tbl)
    }

    partido_col <- tbl[["partido"]]
    all_names <- unique(unlist(lapply(partido_col, function(x) {
        if (is.list(x)) names(x) else character(0)
    })))

    for (nm in all_names) {
        new_name <- paste0("partido_", nm)
        vals <- lapply(partido_col, function(x) {
            if (is.list(x)) {
                v <- x[[nm]]
                if (is.null(v)) NA else v
            } else {
                NA
            }
        })
        # Keep as list-column only if nested
        is_nested <- any(vapply(vals, is.list, logical(1)))
        if (is_nested) {
            tbl[[new_name]] <- vals
        } else {
            tbl[[new_name]] <- unlist(vals)
        }
    }

    tbl[["partido"]] <- NULL
    tbl
}

#' Convert fecha columns from character to Date
#'
#' @param tbl A tibble.
#' @return The tibble with `fecha` column as Date (if present).
#' @noRd
coerce_dates <- function(tbl) {
    if ("fecha" %in% names(tbl)) {
        tbl[["fecha"]] <- as.Date(tbl[["fecha"]])
    }
    tbl
}

#' Coerce integer-typed columns that may have become character due to NA
#'
#' @param tbl A tibble.
#' @param cols Character vector of column names to coerce.
#' @return The tibble with specified columns as integer.
#' @noRd
coerce_integers <- function(tbl, cols) {
    for (col in cols) {
        if (col %in% names(tbl)) {
            tbl[[col]] <- as.integer(tbl[[col]])
        }
    }
    tbl
}
