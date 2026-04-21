# List elections with optional filters

Returns a paginated list of elections. Use `all_pages = TRUE` to
retrieve all matching records automatically.

## Usage

``` r
get_elecciones(
  tipo_eleccion = NULL,
  year = NULL,
  mes = NULL,
  ambito = NULL,
  limit = 50L,
  skip = 0L,
  all_pages = FALSE,
  api_key = NULL
)
```

## Arguments

- tipo_eleccion:

  Character vector. Filter by election type code(s). Valid values: `"A"`
  (Autonomicas), `"E"` (Europeas), `"G"` (Congreso), `"L"` (Locales),
  `"S"` (Senado). Optional.

- year:

  Character vector. Filter by year (e.g. `"2019"`, `c("2019", "2023")`).
  Optional.

- mes:

  Character vector. Filter by month with leading zero (e.g. `"04"`,
  `"11"`). Optional.

- ambito:

  Character vector. Filter by scope (e.g. `"Nacional"`, `"Autonomico"`).
  Optional.

- limit:

  Integer. Maximum records to return per page (1-500, default 50).

- skip:

  Integer. Records to skip (default 0).

- all_pages:

  Logical. If `TRUE`, fetches all pages automatically. Default `FALSE`.

- api_key:

  (Opcional) Clave de API para sobrescribir la global solo en esta
  llamada.

## Value

A tibble with columns: `id`, `tipo_eleccion`, `year`, `mes`, `dia`,
`fecha` (Date), `descripcion`, `ambito`, `slug`.

The tibble has an `"edb_total"` attribute with the total record count.

## Examples

``` r
if (FALSE) { # \dontrun{
# All general elections
get_elecciones(tipo_eleccion = "G")

# General elections in 2019
get_elecciones(tipo_eleccion = "G", year = "2019")

# Fetch all elections (all pages)
get_elecciones(all_pages = TRUE)
} # }
```
