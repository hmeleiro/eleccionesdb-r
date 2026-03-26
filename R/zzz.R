# Package-level environment for mutable state
.eleccionesdb_env <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
    url <- Sys.getenv("ELECCIONESDB_URL", unset = "http://localhost:8000")
    # Strip trailing slash

    url <- sub("/+$", "", url)
    .eleccionesdb_env$base_url <- url
}
