# Results by municipality

A convenience wrapper around
[`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md)
that pre-sets `tipo_territorio = "municipio"`. All other parameters are
passed through unchanged. See
[`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md)
for the full parameter reference and details on the returned tibble.

## Usage

``` r
get_municipios(...)

getMunicipios(...)
```

## Arguments

- ...:

  Arguments passed to
  [`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md).
  The `tipo_territorio` parameter is fixed to `"municipio"` and cannot
  be overridden.

## Value

A tibble as returned by
[`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md)
filtered to `tipo_territorio = "municipio"`.

## Functions

- `getMunicipios()`: Retrocompatibility alias for `get_municipios()`.
  Maintained for backwards compatibility. Prefer `get_municipios()` in
  new code.

## Examples

``` r
if (FALSE) { # \dontrun{
# Municipal results in a province (Almeria = "04")
get_municipios(tipo_eleccion = "G", year = "2019",
               codigo_provincia = "04", all_pages = TRUE)
} # }
```
