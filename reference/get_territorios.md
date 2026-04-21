# List territories with optional filters

Returns a paginated list of territories. Supports filtering by type,
administrative codes, and partial name search.

## Usage

``` r
get_territorios(
  tipo = NULL,
  codigo_ccaa = NULL,
  codigo_provincia = NULL,
  codigo_municipio = NULL,
  codigo_circunscripcion = NULL,
  nombre = NULL,
  limit = 50L,
  skip = 0L,
  all_pages = FALSE,
  api_key = NULL
)
```

## Arguments

- tipo:

  Character vector. Filter by territory type. Valid values: `"ccaa"`,
  `"provincia"`, `"municipio"`, `"distrito"`, `"seccion"`,
  `"circunscripcion"`, `"cera"`. Optional.

- codigo_ccaa:

  Character vector. Filter by autonomous community INE code(s) (e.g.
  `"01"`, `"13"`). Optional.

- codigo_provincia:

  Character vector. Filter by province INE code(s) (e.g. `"28"`,
  `"08"`). Optional.

- codigo_municipio:

  Character vector. Filter by municipality INE code(s). Optional.

- codigo_circunscripcion:

  Character vector. Filter by constituency code. Optional.

- nombre:

  Character. Partial name search, case-insensitive (e.g. `"madrid"`).
  Optional.

- limit:

  Integer. Maximum records per page (1-500, default 50).

- skip:

  Integer. Records to skip (default 0).

- all_pages:

  Logical. If `TRUE`, fetches all pages. Default `FALSE`.

- api_key:

  (Opcional) Clave de API para sobrescribir la global solo en esta
  llamada.

## Value

A tibble with columns: `id`, `tipo`, `nombre`, `codigo_completo`,
`codigo_ccaa`, `codigo_provincia`.

## Examples

``` r
if (FALSE) { # \dontrun{
# All autonomous communities
get_territorios(tipo = "ccaa")

# Search by name
get_territorios(nombre = "madrid", tipo = "provincia")

# Provinces in Andalucia (codigo_ccaa = "01")
get_territorios(tipo = "provincia", codigo_ccaa = "01", all_pages = TRUE)
} # }
```
