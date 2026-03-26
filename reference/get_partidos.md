# List political parties with optional filters

Returns a paginated list of parties. Supports partial search by
abbreviation (`siglas`) and full name (`denominacion`), and filtering by
recode group.

## Usage

``` r
get_partidos(
  siglas = NULL,
  denominacion = NULL,
  partido_recode_id = NULL,
  limit = 50L,
  skip = 0L,
  all_pages = FALSE
)
```

## Arguments

- siglas:

  Character. Partial search by party abbreviation, case-insensitive
  (e.g. `"psoe"`). Optional.

- denominacion:

  Character. Partial search by full party name, case-insensitive (e.g.
  `"socialista"`). Optional.

- partido_recode_id:

  Integer vector. Filter by recode/group ID(s). Optional.

- limit:

  Integer. Maximum records per page (1-500, default 50).

- skip:

  Integer. Records to skip (default 0).

- all_pages:

  Logical. If `TRUE`, fetches all pages. Default `FALSE`.

## Value

A tibble with columns: `id`, `siglas`, `denominacion`,
`partido_recode_id`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Search for PSOE-related parties
get_partidos(siglas = "psoe")

# All parties in a specific recode group
get_partidos(partido_recode_id = 80, all_pages = TRUE)
} # }
```
