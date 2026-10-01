# Assign AQI categories and colors to a pollutant grid

Classifies pollutant concentrations according to the U.S. Environmental
Protection Agency (EPA) Air Quality Index (AQI) breakpoints and assigns
a color to each grid cell for visualization.

## Usage

``` r
map_colors(grid, pollutant)
```

## Arguments

- grid:

  An `sf` object containing a pollutant concentration field named
  `value`.

- pollutant:

  Character. Pollutant name. Supported pollutants are `"PM2.5"`,
  `"PM10"`, `"CO"`, `"SO2"`, `"NO2"` and `"O3"`.

## Value

The input `sf` object with two additional columns: `category` and
`color`.

## Details

Two new columns are added to the input grid:

- category:

  AQI category assigned according to the pollutant concentration.

- color:

  Hexadecimal color associated with the AQI category.

AQI breakpoints follow the U.S. EPA Air Quality Index.

## Examples

``` r
if (FALSE) { # \dontrun{
# grid must be an sf object containing
# a pollutant concentration column named "value"

colored_grid <- map_colors(
  grid = pollutant_grid,
  pollutant = "PM2.5"
)
} # }
```
