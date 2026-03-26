# ----- parse_paginated -----

test_that("parse_paginated returns tibble from paginated response", {
    tbl <- parse_paginated(fixture_elecciones_pag)
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 3)
    expect_equal(attr(tbl, "edb_total"), 254L)
    expect_true("id" %in% names(tbl))
    expect_true("tipo_eleccion" %in% names(tbl))
})

test_that("parse_paginated handles empty data", {
    tbl <- parse_paginated(fixture_empty_pag)
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 0)
    expect_equal(attr(tbl, "edb_total"), 0L)
})

# ----- parse_single -----

test_that("parse_single returns 1-row tibble", {
    tbl <- parse_single(fixture_health)
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 1)
    expect_equal(tbl$status, "ok")
})

# ----- parse_array -----

test_that("parse_array returns tibble from array", {
    tbl <- parse_array(fixture_tipos_eleccion)
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 5)
    expect_equal(tbl$codigo, c("A", "E", "G", "L", "S"))
})

# ----- safe_tibble -----

test_that("safe_tibble handles NULL values as NA", {
    data <- list(
        list(a = 1L, b = "x", c = NULL),
        list(a = 2L, b = NULL, c = "y")
    )
    tbl <- safe_tibble(data)
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 2)
    expect_true(is.na(tbl$c[1]))
    expect_true(is.na(tbl$b[2]))
})

test_that("safe_tibble returns empty tibble for empty list", {
    tbl <- safe_tibble(list())
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 0)
})

test_that("safe_tibble preserves nested objects as list columns", {
    data <- list(
        list(id = 1L, nested = list(a = "x", b = 1)),
        list(id = 2L, nested = list(a = "y", b = 2))
    )
    tbl <- safe_tibble(data)
    expect_true(is.list(tbl$nested))
})

# ----- flatten_nested -----

test_that("flatten_nested expands nested object into prefixed columns", {
    tbl <- parse_single(fixture_eleccion_detail)
    tbl <- flatten_nested(tbl, "tipo", "tipo")
    expect_true("tipo_codigo" %in% names(tbl))
    expect_true("tipo_descripcion" %in% names(tbl))
    expect_false("tipo" %in% names(tbl))
    expect_equal(tbl$tipo_codigo, "G")
})

test_that("flatten_nested handles NULL nested object", {
    tbl <- parse_single(fixture_partido_without_recode)
    tbl <- flatten_nested(tbl, "recode", "recode")
    # recode was NULL, so no new columns are added, original is dropped
    expect_false("recode" %in% names(tbl))
})

test_that("flatten_nested with recode present", {
    tbl <- parse_single(fixture_partido_with_recode)
    tbl <- flatten_nested(tbl, "recode", "recode")
    expect_true("recode_id" %in% names(tbl))
    expect_true("recode_agrupacion" %in% names(tbl))
    expect_equal(tbl$recode_partido_recode, "IU")
})

# ----- coerce_dates -----

test_that("coerce_dates converts fecha to Date", {
    tbl <- tibble::tibble(fecha = c("2019-04-28", "2019-11-10"))
    tbl <- coerce_dates(tbl)
    expect_s3_class(tbl$fecha, "Date")
    expect_equal(tbl$fecha[1], as.Date("2019-04-28"))
})

test_that("coerce_dates is a no-op without fecha column", {
    tbl <- tibble::tibble(x = 1:3)
    result <- coerce_dates(tbl)
    expect_identical(tbl, result)
})

# ----- flatten_combinados -----

test_that("flatten_combinados flattens all nested objects", {
    tbl <- parse_paginated(fixture_combinados_pag)
    tbl <- flatten_combinados(tbl)

    # partido fields

    expect_true("partido_siglas" %in% names(tbl))
    expect_true("partido_denominacion" %in% names(tbl))
    expect_false("partido" %in% names(tbl))

    # recode fields
    expect_true("recode_agrupacion" %in% names(tbl))
    expect_true("recode_color" %in% names(tbl))

    # territorio fields
    expect_true("territorio_nombre" %in% names(tbl))
    expect_true("territorio_tipo" %in% names(tbl))
    expect_false("territorio" %in% names(tbl))

    # eleccion fields
    expect_true("eleccion_year" %in% names(tbl))
    expect_false("eleccion" %in% names(tbl))
})

test_that("flatten_combinados handles empty tibble", {
    tbl <- tibble::tibble()
    result <- flatten_combinados(tbl)
    expect_equal(nrow(result), 0)
})

# ----- flatten_partido -----

test_that("flatten_partido flattens partido in votos", {
    tbl <- safe_tibble(fixture_resultado_completo$votos_partido)
    tbl <- flatten_partido(tbl)
    expect_true("partido_siglas" %in% names(tbl))
    expect_false("partido" %in% names(tbl))
    expect_equal(tbl$partido_siglas[1], "PSOE")
})
