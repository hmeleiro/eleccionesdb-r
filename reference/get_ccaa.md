# Results by autonomous community

A convenience wrapper around
[`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md)
that pre-sets `tipo_territorio = "ccaa"`. See
[`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md)
for full details on the returned tibble.

## Usage

``` r
get_ccaa(
  year = NULL,
  tipo_eleccion = NULL,
  codigo_ccaa = NULL,
  codigo_provincia = NULL,
  codigo_municipio = NULL,
  ...,
  eleccion_id = NULL,
  territorio_id = NULL,
  partido_id = NULL,
  limit = 50L,
  skip = 0L,
  all_pages = TRUE,
  clean = TRUE,
  api_key = NULL
)
```

## Arguments

- year:

  Character vector. Filter by year(s). Optional.

- tipo_eleccion:

  Character vector. Filter by election type code(s). Valid values: `"A"`
  (Autonomicas), `"E"` (Europeas), `"G"` (Congreso), `"L"` (Locales),
  `"S"` (Senado). Optional.

- codigo_ccaa:

  Character vector. Filter by autonomous community INE code(s) (e.g.
  `"01"`, `"13"`). Optional.

- codigo_provincia:

  Character vector. Filter by province INE code(s) (e.g. `"28"`,
  `"08"`). Optional.

- codigo_municipio:

  Character vector. Filter by municipality INE code(s). Optional.

- ...:

  Arguments after `...` must be named.

- eleccion_id:

  Integer vector. Filter by election ID(s). Optional.

- territorio_id:

  Integer vector. Filter by territory ID(s). Optional.

- partido_id:

  Integer vector. Filter by party ID(s). Optional.

- limit:

  Integer. Maximum records per page (1-500, default 50).

- skip:

  Integer. Records to skip (default 0).

- all_pages:

  Logical. If `TRUE`, fetches all pages automatically. Default `TRUE`.

- clean:

  Logical. If `TRUE` (default), renames prefixed columns to short names
  and selects only user-friendly columns. If `FALSE`, returns all
  flattened columns.

- api_key:

  Character. Optional API key to override the global setting for this
  call only.

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
