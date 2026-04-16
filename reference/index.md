# Package index

## Elecciones

- [`get_tipos_eleccion()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_tipos_eleccion.md)
  : List all election types
- [`get_tipo_eleccion()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_tipo_eleccion.md)
  : Get a single election type by code
- [`get_elecciones()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_elecciones.md)
  : List elections with optional filters
- [`get_eleccion()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_eleccion.md)
  : Get a single election by ID

## Territorios

- [`get_territorios()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_territorios.md)
  : List territories with optional filters
- [`get_territorio()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_territorio.md)
  : Get a single territory by ID
- [`get_territorio_hijos()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_territorio_hijos.md)
  : List child territories (hierarchical navigation)

## Partidos

- [`get_partidos()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_partidos.md)
  : List political parties with optional filters
- [`get_partido()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_partido.md)
  : Get a single party by ID
- [`get_partidos_recode()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_partidos_recode.md)
  : List party recode/groups with optional filter
- [`get_partido_recode()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_partido_recode.md)
  : Get a single party recode/group by ID

## Resultados

- [`get_totales_territorio_eleccion()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_totales_territorio_eleccion.md)
  : List territorial totals for an election
- [`get_resultado_completo()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultado_completo.md)
  : Get complete result for an election and territory
- [`get_resultados()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_resultados.md)
  : List combined results (fully expanded)
- [`get_totales_territorio()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_totales_territorio.md)
  : List territorial totals (cross-election)
- [`get_votos_partido()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_votos_partido.md)
  : List per-party votes (cross-election)

## Voto exterior (CERA)

- [`get_cera_resumen()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_cera_resumen.md)
  : List CERA (overseas vote) summaries
- [`get_cera_votos()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_cera_votos.md)
  : List CERA (overseas) per-party votes

## Utilidades

- [`get_health()`](https://hmeleiro.github.io/eleccionesdb-r/reference/get_health.md)
  : Check API health status

## Configuración avanzada

Funciones para apuntar el paquete a una instancia propia de la API. Ver
[`vignette("autodespliegue")`](https://hmeleiro.github.io/eleccionesdb-r/articles/autodespliegue.md)
para más detalles.

- [`edb_set_base_url()`](https://hmeleiro.github.io/eleccionesdb-r/reference/edb_set_base_url.md)
  : Set the EleccionesDB API base URL
- [`edb_get_base_url()`](https://hmeleiro.github.io/eleccionesdb-r/reference/edb_get_base_url.md)
  : Get the current EleccionesDB API base URL
