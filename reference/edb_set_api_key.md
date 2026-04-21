# Set the EleccionesDB API key

Guarda la clave de API globalmente para todas las peticiones protegidas.
Por defecto, la clave se almacena en la opción de R y en la variable de
entorno para la sesión actual. Si `persist = TRUE`, también se añade a
tu archivo `.Renviron` para que esté disponible en futuras sesiones.

## Usage

``` r
edb_set_api_key(key, persist = FALSE)
```

## Arguments

- key:

  Cadena de texto con la API key.

- persist:

  Lógico. Si `TRUE`, guarda la clave en tu `.Renviron` de usuario.

## Value

Invisiblemente, la clave anterior (si existía).

## Examples

``` r
if (FALSE) { # \dontrun{
edb_set_api_key("TU_API_KEY")
} # }
```
