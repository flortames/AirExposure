# Create example hourly pollutant grids

Creates a regular spatial grid over a user-defined bounding box and
exports 24 hourly shapefiles. Each grid cell is assigned a random value,
making this function useful for generating example datasets and testing
workflows.

## Usage

``` r
make_grid(ymin, ymax, xmin, xmax, pixelSize, dir, date, values = NULL)
```

## Arguments

- ymin:

  Numeric. Minimum latitude of the grid extent.

- ymax:

  Numeric. Maximum latitude of the grid extent.

- xmin:

  Numeric. Minimum longitude of the grid extent.

- xmax:

  Numeric. Maximum longitude of the grid extent.

- pixelSize:

  Numeric. Grid cell size in meters.

- dir:

  Character. Directory where the shapefiles will be written.

- date:

  Character. Date used in the output filenames (`"YYYY-mm-dd"`).

- values:

  Optional. Currently unused.

## Value

This function is called for its side effect of writing shapefiles to
disk. No value is returned.

## Details

The function creates one shapefile for each hour of the day. Pollutant
values are generated randomly and are intended only for examples and
testing.

## Examples

``` r
if (FALSE) { # \dontrun{
make_grid(
  ymin = -31.6,
  ymax = -31.3,
  xmin = -64.3,
  xmax = -64.0,
  pixelSize = 1000,
  dir = "example_grids/",
  date = "2019-08-01"
)
} # }
```
