# Results by province

A convenience wrapper around
[`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md)
that pre-sets `tipo_territorio = "provincia"`. All other parameters are
passed through unchanged. See
[`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md)
for the full parameter reference and details on the returned tibble.

## Usage

``` r
get_provincias(...)

getProvincias(...)
```

## Arguments

- ...:

  Arguments passed to
  [`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md).
  The `tipo_territorio` parameter is fixed to `"provincia"` and cannot
  be overridden.

## Value

A tibble as returned by
[`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md)
filtered to `tipo_territorio = "provincia"`.

## Functions

- `getProvincias()`: Retrocompatibility alias for `get_provincias()`.
  Maintained for backwards compatibility. Prefer `get_provincias()` in
  new code.

## Examples

``` r
if (FALSE) { # \dontrun{
# Provincial results for general elections in Andalucia
get_provincias(tipo_eleccion = "G", year = "2019",
              codigo_ccaa = "01", all_pages = TRUE)

# Compare PSOE votes across all provinces in 2019
library(dplyr)
get_provincias(tipo_eleccion = "G", year = "2019", all_pages = TRUE) |>
    filter(siglas == "PSOE") |>
    arrange(desc(votos))
} # }
```
