# List combined results (fully expanded)

Returns paginated votes with party (including recode), territory, and
election information fully expanded and flattened into a wide tibble.
This is the most convenient function for cross-dimensional analysis.

## Usage

``` r
get_resultados(
  year = NULL,
  tipo_eleccion = NULL,
  tipo_territorio = NULL,
  codigo_ccaa = NULL,
  codigo_provincia = NULL,
  ...,
  eleccion_id = NULL,
  territorio_id = NULL,
  partido_id = NULL,
  limit = 50L,
  skip = 0L,
  all_pages = FALSE,
  clean = TRUE
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

- partido_id:

  Integer vector. Filter by party ID(s). Optional.

- limit:

  Integer. Maximum records per page (1-500, default 50).

- skip:

  Integer. Records to skip (default 0).

- all_pages:

  Logical. If `TRUE`, fetches all pages. Default `FALSE`.

- clean:

  Logical. If `TRUE` (default), renames prefixed columns and selects
  only user-friendly columns. If `FALSE`, returns all flattened columns.

## Value

A tibble. When `clean = TRUE`: `year`, `mes`, `tipo_eleccion`,
`tipo_territorio`, `territorio_nombre`, `codigo_ccaa`,
`codigo_provincia`, `siglas`, `denominacion`, `partido_recode`, `votos`,
`representantes`. When `clean = FALSE`: all flattened columns with
prefixes `partido_*`, `recode_*`, `territorio_*`, `eleccion_*`.

## Details

When `clean = TRUE` (the default), prefixed columns are renamed to short
names and only the most useful subset is returned: `year`, `mes`,
`tipo_eleccion`, `tipo_territorio`, `territorio_nombre`, `codigo_ccaa`,
`codigo_provincia`, `siglas`, `denominacion`, `partido_recode`, `votos`,
`representantes`.

Set `clean = FALSE` to get the full flattened tibble with all prefixed
columns (`partido_*`, `recode_*`, `territorio_*`, `eleccion_*`).

## Examples

``` r
if (FALSE) { # \dontrun{
# Provincial results for general elections in Andalucia (clean)
get_resultados(
    tipo_eleccion = "G", year = "2019",
    tipo_territorio = "provincia",
    codigo_ccaa = "01",
    all_pages = TRUE
)

# Full flattened output
get_resultados(
    tipo_eleccion = "G", year = "2019",
    tipo_territorio = "provincia",
    clean = FALSE
)
} # }
```
