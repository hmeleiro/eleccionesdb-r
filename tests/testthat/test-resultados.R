test_that("get_totales_territorio_eleccion returns paginated tibble", {
    local_mocked_bindings(edb_get = function(...) fixture_resumen_pag)
    tbl <- get_totales_territorio_eleccion(208, tipo_territorio = "provincia")
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 2)
    expect_true("censo_ine" %in% names(tbl))
    expect_true("nrepresentantes" %in% names(tbl))
    expect_true(is.na(tbl$participacion_3[1]))
})

test_that("get_resultado_completo returns list with totales_territorio and votos_partido", {
    local_mocked_bindings(edb_get = function(...) fixture_resultado_completo)
    result <- get_resultado_completo(208, 20)
    expect_type(result, "list")
    expect_named(result, c("totales_territorio", "votos_partido"))

    # totales_territorio
    expect_s3_class(result$totales_territorio, "tbl_df")
    expect_equal(nrow(result$totales_territorio), 1)
    expect_equal(result$totales_territorio$censo_ine, 500556L)

    # votos_partido with flattened partido
    expect_s3_class(result$votos_partido, "tbl_df")
    expect_equal(nrow(result$votos_partido), 2)
    expect_true("partido_siglas" %in% names(result$votos_partido))
    expect_false("partido" %in% names(result$votos_partido))
})

test_that("get_totales_territorio returns paginated tibble", {
    local_mocked_bindings(edb_get = function(...) fixture_resumen_pag)
    tbl <- get_totales_territorio(eleccion_id = 208, tipo_territorio = "provincia")
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 2)
})

test_that("get_votos_partido returns paginated tibble", {
    local_mocked_bindings(edb_get = function(...) fixture_votos_pag)
    tbl <- get_votos_partido(eleccion_id = 208, territorio_id = 20)
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 2)
    expect_true("votos" %in% names(tbl))
    expect_true("representantes" %in% names(tbl))
})

test_that("get_resultados returns clean tibble by default", {
    local_mocked_bindings(edb_get = function(...) fixture_combinados_pag)
    tbl <- get_resultados(eleccion_id = 208)
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 1)

    # Verify clean renamed columns
    expect_true("siglas" %in% names(tbl))
    expect_true("partido_recode" %in% names(tbl))
    expect_true("territorio_nombre" %in% names(tbl))
    expect_true("year" %in% names(tbl))
    expect_true("votos" %in% names(tbl))
    expect_true("representantes" %in% names(tbl))

    # No raw nested or prefixed columns
    expect_false("partido" %in% names(tbl))
    expect_false("territorio" %in% names(tbl))
    expect_false("eleccion" %in% names(tbl))
    expect_false("id" %in% names(tbl))
    expect_false("partido_siglas" %in% names(tbl))
})

test_that("get_resultados with clean = FALSE returns full flattened tibble", {
    local_mocked_bindings(edb_get = function(...) fixture_combinados_pag)
    tbl <- get_resultados(eleccion_id = 208, clean = FALSE)
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 1)

    # Verify full flattened columns
    expect_true("partido_siglas" %in% names(tbl))
    expect_true("recode_agrupacion" %in% names(tbl))
    expect_true("territorio_nombre" %in% names(tbl))
    expect_true("eleccion_year" %in% names(tbl))

    # No raw nested columns
    expect_false("partido" %in% names(tbl))
    expect_false("territorio" %in% names(tbl))
    expect_false("eleccion" %in% names(tbl))
})

test_that("get_health returns 1-row tibble", {
    local_mocked_bindings(edb_get = function(...) fixture_health)
    tbl <- get_health()
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 1)
    expect_equal(tbl$status, "ok")
})
