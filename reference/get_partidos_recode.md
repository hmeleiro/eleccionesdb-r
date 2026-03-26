# List party recode/groups with optional filter

Returns a paginated list of party recodes (groupings/families).

## Usage

``` r
get_partidos_recode(
  agrupacion = NULL,
  limit = 50L,
  skip = 0L,
  all_pages = FALSE
)
```

## Arguments

- agrupacion:

  Character. Partial search by grouping name, case-insensitive (e.g.
  `"PCE/IU"`). Optional.

- limit:

  Integer. Maximum records per page (1-500, default 50).

- skip:

  Integer. Records to skip (default 0).

- all_pages:

  Logical. If `TRUE`, fetches all pages. Default `FALSE`.

## Value

A tibble with columns: `id`, `partido_recode`, `agrupacion`, `color`.

## Examples

``` r
if (FALSE) { # \dontrun{
# All recode groups
get_partidos_recode(all_pages = TRUE)

# Search by grouping
get_partidos_recode(agrupacion = "PCE/IU")
} # }
```
