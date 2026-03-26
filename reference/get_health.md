# Check API health status

Queries the `/health` endpoint and returns the status of the API and its
database connection.

## Usage

``` r
get_health()
```

## Value

A 1-row tibble with columns `status`, `environment`, `database`.

## Examples

``` r
if (FALSE) { # \dontrun{
get_health()
} # }
```
