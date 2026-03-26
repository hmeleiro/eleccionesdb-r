# Get a single election by ID

Returns the full detail of an election, including the election type as
expanded columns (`tipo_codigo`, `tipo_descripcion`).

## Usage

``` r
get_eleccion(eleccion_id)
```

## Arguments

- eleccion_id:

  Integer. The election ID.

## Value

A 1-row tibble with columns: `id`, `tipo_eleccion`, `year`, `mes`,
`dia`, `fecha` (Date), `codigo_ccaa`, `numero_vuelta`, `descripcion`,
`ambito`, `slug`, `tipo_codigo`, `tipo_descripcion`.

## Examples

``` r
if (FALSE) { # \dontrun{
get_eleccion(208)
} # }
```
