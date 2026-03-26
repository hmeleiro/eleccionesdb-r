test_that("get_partidos returns paginated tibble", {
    local_mocked_bindings(edb_get = function(...) fixture_partidos_pag)
    tbl <- get_partidos(siglas = "psoe")
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 2)
    expect_true("siglas" %in% names(tbl))
})

test_that("get_partido flattens recode when present", {
    local_mocked_bindings(edb_get = function(...) fixture_partido_with_recode)
    tbl <- get_partido(5082)
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 1)
    expect_true("recode_id" %in% names(tbl))
    expect_true("recode_agrupacion" %in% names(tbl))
    expect_equal(tbl$recode_partido_recode, "IU")
})

test_that("get_partido handles null recode", {
    local_mocked_bindings(edb_get = function(...) fixture_partido_without_recode)
    tbl <- get_partido(11911)
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 1)
    expect_true(is.na(tbl$partido_recode_id))
    # recode column should be dropped (no recode_ columns added since all NULL)
    expect_false("recode" %in% names(tbl))
})

test_that("get_partidos_recode returns paginated tibble", {
    fixture_recode_pag <- list(
        total = 178L, skip = 0L, limit = 3L,
        data = list(
            list(
                id = 1L, partido_recode = "AA",
                agrupacion = "OtrosRep", color = "#23C27A"
            )
        )
    )
    local_mocked_bindings(edb_get = function(...) fixture_recode_pag)
    tbl <- get_partidos_recode()
    expect_s3_class(tbl, "tbl_df")
    expect_equal(nrow(tbl), 1)
    expect_true("color" %in% names(tbl))
})

test_that("get_partido_recode returns list with recode and partidos", {
    local_mocked_bindings(edb_get = function(...) fixture_partido_recode_detail)
    result <- get_partido_recode(47)
    expect_type(result, "list")
    expect_named(result, c("recode", "partidos"))
    expect_s3_class(result$recode, "tbl_df")
    expect_equal(nrow(result$recode), 1)
    expect_equal(result$recode$partido_recode, "IU")
    expect_s3_class(result$partidos, "tbl_df")
    expect_equal(nrow(result$partidos), 2)
})
