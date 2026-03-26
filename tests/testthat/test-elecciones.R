test_that("get_tipos_eleccion returns correct tibble", {
    local_mocked_bindings(edb_get = function(...) fixture_tipos_eleccion)
    tbl <- get_tipos_eleccion()
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 5)
    expect_equal(names(tbl), c("codigo", "descripcion"))
})

test_that("get_tipo_eleccion returns 1-row tibble", {
    local_mocked_bindings(edb_get = function(...) fixture_tipo_eleccion_g)
    tbl <- get_tipo_eleccion("G")
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 1)
    expect_equal(tbl$codigo, "G")
})

test_that("get_elecciones returns paginated tibble with dates", {
    local_mocked_bindings(edb_get = function(...) fixture_elecciones_pag)
    tbl <- get_elecciones()
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 3)
    expect_s3_class(tbl$fecha, "Date")
    expect_equal(attr(tbl, "edb_total"), 254L)
})

test_that("get_elecciones handles empty result", {
    local_mocked_bindings(edb_get = function(...) fixture_empty_pag)
    tbl <- get_elecciones(tipo_eleccion = "G", year = "1800")
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 0)
})

test_that("get_eleccion flattens tipo and coerces dates", {
    local_mocked_bindings(edb_get = function(...) fixture_eleccion_detail)
    tbl <- get_eleccion(208)
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 1)
    expect_true("tipo_codigo" %in% names(tbl))
    expect_true("tipo_descripcion" %in% names(tbl))
    expect_false("tipo" %in% names(tbl))
    expect_s3_class(tbl$fecha, "Date")
})
