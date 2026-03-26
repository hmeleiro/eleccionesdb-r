test_that("edb_set_base_url validates input", {
    expect_error(edb_set_base_url(123))
    expect_error(edb_set_base_url(""))
    expect_error(edb_set_base_url(c("a", "b")))
})

test_that("edb_set_base_url and edb_get_base_url work", {
    old <- edb_get_base_url()
    withr::defer(edb_set_base_url(old))

    edb_set_base_url("http://example.com:9000")
    expect_equal(edb_get_base_url(), "http://example.com:9000")
})

test_that("edb_set_base_url strips trailing slash", {
    old <- edb_get_base_url()
    withr::defer(edb_set_base_url(old))

    edb_set_base_url("http://example.com:9000///")
    expect_equal(edb_get_base_url(), "http://example.com:9000")
})

test_that("edb_set_base_url returns old URL invisibly", {
    old <- edb_get_base_url()
    withr::defer(edb_set_base_url(old))

    result <- edb_set_base_url("http://new-url.com")
    expect_equal(result, old)
})

test_that(".onLoad reads ELECCIONESDB_URL env var", {
    old <- edb_get_base_url()
    withr::defer(edb_set_base_url(old))

    withr::with_envvar(
        c(ELECCIONESDB_URL = "http://from-env.com:1234"),
        {
            .onLoad(NULL, NULL)
            expect_equal(edb_get_base_url(), "http://from-env.com:1234")
        }
    )
})
