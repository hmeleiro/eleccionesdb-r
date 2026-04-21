# Results by census section

A convenience wrapper around
[`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md)
that pre-sets `tipo_territorio = "seccion"`. All other parameters are
passed through unchanged. See
[`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md)
for the full parameter reference and details on the returned tibble.

## Usage

``` r
get_secciones(...)

getSecciones(...)
```

## Arguments

- ...:

  Arguments passed to
  [`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md).
  The `tipo_territorio` parameter is fixed to `"seccion"` and cannot be
  overridden.

## Value

A tibble as returned by
[`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md)
filtered to `tipo_territorio = "seccion"`.

## Details

Note: section-level data can be very large. Always use filters
(`codigo_provincia`, `codigo_municipio`, etc.) or `all_pages = FALSE` to
limit the response size.

## Functions

- `getSecciones()`: Retrocompatibility alias for `get_secciones()`.
  Maintained for backwards compatibility. Prefer `get_secciones()` in
  new code.

## Examples

``` r
if (FALSE) { # \dontrun{
# Section-level results for a municipality
get_secciones(tipo_eleccion = "G", year = "2019",
              codigo_municipio = "028079", all_pages = TRUE)
} # }
```
