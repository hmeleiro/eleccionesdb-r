test_that("edb_set_api_key guarda y recupera la clave correctamente", {
    old <- edb_get_api_key()
    withr::defer(edb_set_api_key(old))

    expect_null(edb_get_api_key())
    edb_set_api_key("CLAVE_TEST")
    expect_equal(edb_get_api_key(), "CLAVE_TEST")
})

test_that("edb_set_api_key persiste en .Renviron si persist = TRUE", {
    tmp_env <- tempfile()
    file.copy("~/.Renviron", tmp_env, overwrite = TRUE)
    withr::defer(file.copy(tmp_env, "~/.Renviron", overwrite = TRUE))

    edb_set_api_key("CLAVE_PERSIST", persist = TRUE)
    lines <- readLines("~/.Renviron")
    expect_true(any(grepl("^ELECCIONESDB_API_KEY=CLAVE_PERSIST", lines)))
})

test_that("edb_base_request añade header X-API-Key solo en endpoints protegidos", {
    edb_set_api_key("CLAVE_HEADER")
    req <- edb_base_request("/v1/partidos")
    headers <- httr2::req_headers(req)
    expect_true("X-API-Key" %in% names(headers))
    expect_equal(headers[["X-API-Key"]], "CLAVE_HEADER")

    req2 <- edb_base_request("/health")
    headers2 <- httr2::req_headers(req2)
    expect_false("X-API-Key" %in% names(headers2))
})

test_that("error claro si falta la clave en endpoint protegido", {
    edb_set_api_key("")
    expect_error(edb_base_request("/v1/partidos"),
                 "requiere autenticación por API key")
})

test_that("api_key explícita sobrescribe la global", {
    edb_set_api_key("CLAVE_GLOBAL")
    req <- edb_base_request("/v1/partidos", api_key = "CLAVE_EXPL")
    headers <- httr2::req_headers(req)
    expect_equal(headers[["X-API-Key"]], "CLAVE_EXPL")
})
