# Results by autonomous community

A convenience wrapper around
[`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md)
that pre-sets `tipo_territorio = "ccaa"`. All other parameters are
passed through unchanged. See
[`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md)
for the full parameter reference and details on the returned tibble.

## Usage

``` r
get_ccaa(...)
```

## Arguments

- ...:

  Arguments passed to
  [`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md).
  The `tipo_territorio` parameter is fixed to `"ccaa"` and cannot be
  overridden.

## Value

A tibble as returned by
[`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md)
filtered to `tipo_territorio = "ccaa"`.

## Examples

``` r
if (FALSE) { # \dontrun{
# CCAA-level results for general elections in 2019
get_ccaa(tipo_eleccion = "G", year = "2019", all_pages = TRUE)

# Use dplyr to compare turnout across CCAA
library(dplyr)
get_ccaa(tipo_eleccion = "G", year = "2019", all_pages = TRUE) |>
    distinct(territorio_nombre, censo_ine, votos_validos) |>
    mutate(participacion = votos_validos / censo_ine)
} # }
```
