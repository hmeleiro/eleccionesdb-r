# List child territories (hierarchical navigation)

Returns the direct children of a territory. For example, provinces
within an autonomous community, or municipalities within a province.

## Usage

``` r
get_territorio_hijos(territorio_id, limit = 50L, skip = 0L, all_pages = FALSE)
```

## Arguments

- territorio_id:

  Integer. The parent territory ID.

- limit:

  Integer. Maximum records per page (1-500, default 50).

- skip:

  Integer. Records to skip (default 0).

- all_pages:

  Logical. If `TRUE`, fetches all pages. Default `FALSE`.

## Value

A tibble with columns: `id`, `tipo`, `nombre`, `codigo_completo`,
`codigo_ccaa`, `codigo_provincia`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Provinces in Andalucia (territory ID 1)
get_territorio_hijos(1, all_pages = TRUE)
} # }
```
