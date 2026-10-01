# Estimate Daily Exposure Using the Traditional Model

Estimates daily exposure assuming that an individual remains at the
origin location throughout the entire day. Exposure is calculated by
intersecting the origin point with the daily average pollutant grid and
multiplying the resulting concentration by 24 hours.

## Usage

``` r
traditional_model(origin_point, date, dir, gridID, shapeValue)
```

## Arguments

- origin_point:

  A data frame containing the coordinates of the origin location. It
  must include the columns `longitude` and `latitude`.

- date:

  Character. Date of interest in the format `"YYYY-mm-dd"`.

- dir:

  Character. Directory containing the hourly pollutant grid shapefiles.

- gridID:

  Character. Name of the field containing the grid cell identifier.

- shapeValue:

  Character. Name of the field containing the pollutant concentration
  values.

## Value

A numeric value representing the estimated daily exposure.

## Details

The function retrieves all hourly pollutant grids for the requested day,
computes the daily average concentration using
[`temporary_grid_search()`](https://flortames.github.io/AirExposure/reference/temporary_grid_search.md),
identifies the grid cell containing the origin location, and estimates
daily exposure assuming continuous residence at that location.

## Examples

``` r
if (FALSE) { # \dontrun{
traditional_model(
  origin_point = home_location,
  date = "2019-08-01",
  dir = "path/to/grids",
  gridID = "ID",
  shapeValue = "PM25"
)
} # }
```
