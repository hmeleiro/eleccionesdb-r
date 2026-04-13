# eleccionesdb: R Client for the EleccionesDB API

Provides functions to access the EleccionesDB REST API for Spanish
electoral data. Returns tidy tibbles ready for analysis, supports
automatic pagination, and handles nested JSON structures with sensible
flattening. Covers elections, territories, parties, results, and CERA
(overseas vote) endpoints.

Provides functions to access the EleccionesDB REST API for Spanish
electoral data. All functions return tidy tibbles ready for analysis
with the tidyverse.

## Configuration

The API base URL defaults to `https://api.spainelectoralproject.com/`
and can be configured via:

- The `ELECCIONESDB_URL` environment variable (read on package load)

- [`edb_set_base_url()`](edb_set_base_url.md) at runtime

## Main functions

**Elections:**

- [`get_tipos_eleccion()`](get_tipos_eleccion.md) — catalogue of
  election types

- [`get_tipo_eleccion()`](get_tipo_eleccion.md) — single election type
  by code

- [`get_elecciones()`](get_elecciones.md) — list elections (paginated,
  filterable)

- [`get_eleccion()`](get_eleccion.md) — single election detail

**Territories:**

- [`get_territorios()`](get_territorios.md) — list territories
  (paginated, filterable)

- [`get_territorio()`](get_territorio.md) — single territory detail

- [`get_territorio_hijos()`](get_territorio_hijos.md) — child
  territories (hierarchy)

**Parties:**

- [`get_partidos()`](get_partidos.md) — list parties (paginated,
  filterable)

- [`get_partido()`](get_partido.md) — single party detail (with recode)

- [`get_partidos_recode()`](get_partidos_recode.md) — list recode groups
  (paginated)

- [`get_partido_recode()`](get_partido_recode.md) — single recode group
  with party list

**Results:**

- [`get_totales_territorio_eleccion()`](get_totales_territorio_eleccion.md)
  — territorial totals for an election

- [`get_resultado_completo()`](get_resultado_completo.md) — full result
  (totals + votes) for election+territory

- [`get_totales_territorio()`](get_totales_territorio.md) — territorial
  totals (cross-election)

- [`get_votos_partido()`](get_votos_partido.md) — per-party votes
  (cross-election)

- [`get_resultados()`](get_resultados.md) — fully expanded votes (best
  for analysis)

**CERA (overseas vote):**

- [`get_cera_resumen()`](get_cera_resumen.md) — overseas summaries

- [`get_cera_votos()`](get_cera_votos.md) — overseas per-party votes

## Pagination

All list endpoints support `limit`, `skip`, and `all_pages` parameters.
Set `all_pages = TRUE` to automatically fetch all records.

## See also

Useful links:

- <https://github.com/example/eleccionesdb>

- Report bugs at <https://github.com/example/eleccionesdb/issues>

Useful links:

- <https://github.com/example/eleccionesdb>

- Report bugs at <https://github.com/example/eleccionesdb/issues>

## Author

**Maintainer**: First Last <first.last@example.com>
