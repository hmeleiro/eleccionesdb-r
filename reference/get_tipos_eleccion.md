# List all election types

Retrieves the catalogue of election types. This is a small,
non-paginated endpoint that returns all types directly as an array.

## Usage

``` r
get_tipos_eleccion()
```

## Value

A tibble with columns `codigo` and `descripcion`.

## Examples

``` r
if (FALSE) { # \dontrun{
get_tipos_eleccion()
# # A tibble: 5 x 2
#   codigo descripcion
#   <chr>  <chr>
# 1 A      Autonomicas
# 2 E      Europeas
# 3 G      Congreso
# 4 L      Locales
# 5 S      Senado
} # }
```
