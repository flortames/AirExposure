# Retrieve the Hourly Grid File for a Given Date and Time

Searches a directory containing hourly pollutant grid shapefiles and
returns the filename corresponding to the requested date and hour.

## Usage

``` r
hourly_grid(hour, time_format, dir)
```

## Arguments

- hour:

  Character. Date and time used to identify the grid file.

- time_format:

  Character. Format used to parse `hour`.

- dir:

  Character. Directory containing the hourly grid shapefiles.

## Value

A character string containing the name of the matching shapefile.

## Details

Hourly grid shapefiles are expected to follow the naming convention
`"YYYY-mm-dd_HHMM.shp"`.

## Examples

``` r
if (FALSE) { # \dontrun{
hourly_grid(
  hour = "2019-08-01 08:00:00",
  time_format = "%Y-%m-%d %H:%M:%S",
  dir = "path/to/grids"
)
} # }
```
