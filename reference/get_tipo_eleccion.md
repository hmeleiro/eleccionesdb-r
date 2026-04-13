# Get a single election type by code

Get a single election type by code

## Usage

``` r
get_tipo_eleccion(codigo)
```

## Arguments

- codigo:

  Character. The election type code. Valid values: `"A"` (Autonomicas),
  `"E"` (Europeas), `"G"` (Congreso), `"L"` (Locales), `"S"` (Senado).

## Value

A 1-row tibble with columns `codigo` and `descripcion`.

## Examples

``` r
if (FALSE) { # \dontrun{
get_tipo_eleccion("G")
} # }
```
