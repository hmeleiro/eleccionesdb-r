# Get a single party recode/group by ID

Returns the recode detail and its list of associated parties. Because a
recode group can contain thousands of parties, this function returns a
named list instead of a single tibble.

## Usage

``` r
get_partido_recode(partido_recode_id)
```

## Arguments

- partido_recode_id:

  Integer. The recode group ID.

## Value

A named list with two elements:

- `recode`:

  A 1-row tibble with `id`, `partido_recode`, `agrupacion`, `color`.

- `partidos`:

  A tibble of associated parties with `id`, `siglas`, `denominacion`,
  `partido_recode_id`. Can contain hundreds/thousands of rows.

## Examples

``` r
if (FALSE) { # \dontrun{
result <- get_partido_recode(47)
result$recode
result$partidos
nrow(result$partidos) # Can be ~2200 for IU
} # }
```
