# Get a single territory by ID

Returns the full detail of a territory with all administrative codes.

## Usage

``` r
get_territorio(territorio_id)
```

## Arguments

- territorio_id:

  Integer. The territory ID.

## Value

A 1-row tibble with columns: `id`, `tipo`, `codigo_ccaa`,
`codigo_provincia`, `codigo_municipio`, `codigo_distrito`,
`codigo_seccion`, `codigo_circunscripcion`, `nombre`, `codigo_completo`,
`parent_id`.

## Examples

``` r
if (FALSE) { # \dontrun{
get_territorio(1) # Andalucia
get_territorio(63) # Madrid (province)
} # }
```
