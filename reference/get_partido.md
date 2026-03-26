# Get a single party by ID

Returns the full detail of a party, including its recode/group
information flattened into prefixed columns.

## Usage

``` r
get_partido(partido_id)
```

## Arguments

- partido_id:

  Integer. The party ID.

## Value

A 1-row tibble with columns: `id`, `siglas`, `denominacion`,
`partido_recode_id`, `recode_id`, `recode_partido_recode`,
`recode_agrupacion`, `recode_color`.

## Details

When the party has no recode (`partido_recode_id` is `NA`), the recode
columns will contain `NA`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Party with recode
get_partido(5082)

# Party without recode (PACMA)
get_partido(11911)
} # }
```
