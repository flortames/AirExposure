# Retrieve Pollutant Grid(s) for a Given Time Period

Retrieves the pollutant grid corresponding to a given date and time.
When a time interval spanning multiple hours is provided, the function
averages the pollutant values across all hourly grids and returns a
single grid.

## Usage

``` r
temporary_grid_search(
  start_hour,
  end_hour = NULL,
  dir,
  time_format,
  gridID,
  shapeValue
)
```

## Arguments

- start_hour:

  Character. Start date and time.

- end_hour:

  Optional character. End date and time. If `NULL`, only the grid
  corresponding to `start_hour` is returned.

- dir:

  Character. Directory containing the hourly grid shapefiles.

- time_format:

  Character. Format used to parse `start_hour` and `end_hour`.

- gridID:

  Character. Name of the field containing the grid cell identifier.

- shapeValue:

  Character. Name of the field containing the pollutant concentration
  values.

## Value

An `sf` object containing the pollutant grid corresponding to the
requested hour or the average pollutant grid over the requested time
interval.

## Details

If `start_hour` and `end_hour` span multiple hours, the function
retrieves every corresponding hourly grid, calculates the mean pollutant
concentration for each grid cell, and returns the resulting averaged
grid as an `sf` object.

The returned object is always transformed to the WGS84 geographic
coordinate reference system (EPSG:4326).

## Examples

``` r
if (FALSE) { # \dontrun{
temporary_grid_search(
  start_hour = "2019-08-01 08:00:00",
  end_hour = "2019-08-01 10:00:00",
  dir = "path/to/grids",
  time_format = "%Y-%m-%d %H:%M:%S",
  gridID = "ID",
  shapeValue = "PM25"
)
} # }
```
