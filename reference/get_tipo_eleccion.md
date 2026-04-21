# Get a single election type by code

Get a single election type by code

## Usage

``` r
get_tipo_eleccion(codigo, api_key = NULL)
```

## Arguments

- codigo:

  Character. The election type code. Valid values: `"A"` (Autonomicas),
  `"E"` (Europeas), `"G"` (Congreso), `"L"` (Locales), `"S"` (Senado).

- api_key:

  (Opcional) Clave de API para sobrescribir la global solo en esta
  llamada.

## Value

A 1-row tibble with columns `codigo` and `descripcion`.

## Examples

``` r
if (FALSE) { # \dontrun{
get_tipo_eleccion("G")
} # }
```
