# List CERA (overseas vote) summaries

Returns paginated summaries for the overseas electorate (CERA — Censo de
Espanoles Residentes Ausentes).

## Usage

``` r
get_cera_resumen(
  year = NULL,
  tipo_eleccion = NULL,
  ...,
  eleccion_id = NULL,
  territorio_id = NULL,
  limit = 50L,
  skip = 0L,
  all_pages = FALSE,
  denormalize = FALSE,
  clean = denormalize
)
```

## Arguments

- year:

  Character vector. Filter by year(s). Optional.

- tipo_eleccion:

  Character vector. Filter by election type(s). Optional.

- ...:

  Arguments after `...` must be named.

- eleccion_id:

  Integer vector. Filter by election ID(s). Optional.

- territorio_id:

  Integer vector. Filter by territory ID(s). Optional.

- limit:

  Integer. Maximum records per page (1-500, default 50).

- skip:

  Integer. Records to skip (default 0).

- all_pages:

  Logical. If `TRUE`, fetches all pages. Default `FALSE`.

- denormalize:

  Logical. If `TRUE`, adds descriptive columns next to ID columns:
  `eleccion_descripcion` (after `eleccion_id`) and `territorio_nombre`
  (after `territorio_id`). Requires additional API calls. Default
  `FALSE`.

- clean:

  Logical. If `TRUE`, removes ID and slug columns from the result.
  Defaults to the value of `denormalize`.

## Value

A tibble with columns: `id`, `eleccion_id`, `territorio_id`,
`censo_ine`, `votos_validos`, `abstenciones`, `votos_blancos`,
`votos_nulos`. When `denormalize = TRUE`, additional columns
`eleccion_descripcion` and `territorio_nombre` are inserted after their
corresponding ID columns. When `clean = TRUE`, ID and slug columns are
removed.

## Examples

``` r
if (FALSE) { # \dontrun{
get_cera_resumen(tipo_eleccion = "G", year = "2019")

# With denormalized names (clean by default)
get_cera_resumen(tipo_eleccion = "G", denormalize = TRUE)
} # }
```
