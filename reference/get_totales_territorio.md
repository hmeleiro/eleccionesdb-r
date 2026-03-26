# List territorial totals (cross-election)

Returns paginated territorial totals across elections, with flexible
filters. Unlike
[`get_totales_territorio_eleccion()`](get_totales_territorio_eleccion.md),
this can query across multiple elections.

## Usage

``` r
get_totales_territorio(
  year = NULL,
  tipo_eleccion = NULL,
  tipo_territorio = NULL,
  codigo_ccaa = NULL,
  codigo_provincia = NULL,
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

- tipo_territorio:

  Character vector. Filter by territory type(s). Optional.

- codigo_ccaa:

  Character vector. Filter by CCAA code(s). Optional.

- codigo_provincia:

  Character vector. Filter by province code(s). Optional.

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
`censo_ine`, `participacion_1`, `participacion_2`, `participacion_3`,
`votos_validos`, `abstenciones`, `votos_blancos`, `votos_nulos`,
`nrepresentantes`. When `denormalize = TRUE`, additional columns
`eleccion_descripcion` and `territorio_nombre` are inserted after their
corresponding ID columns. When `clean = TRUE`, ID and slug columns are
removed.

## Examples

``` r
if (FALSE) { # \dontrun{
# Provincial totals for general elections in 2019
get_totales_territorio(
    year = "2019", tipo_eleccion = "G",
    tipo_territorio = "provincia"
)

# With denormalized names (clean by default)
get_totales_territorio(
    year = "2019", tipo_eleccion = "G",
    tipo_territorio = "provincia",
    denormalize = TRUE
)
} # }
```
