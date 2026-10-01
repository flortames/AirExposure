# Compare alternative travel routes using pollutant concentrations

Retrieves alternative routes between an origin and a destination using
the TomTom Routing API and estimates the pollutant exposure associated
with each route by intersecting the trajectories with hourly pollutant
concentration grids.

## Usage

``` r
alternative_trajectories(
  origin,
  dest,
  mode,
  dir,
  key,
  output,
  hours = NULL,
  gridID,
  shapeValue,
  units,
  pollutant
)
```

## Arguments

- origin:

  Character string containing the origin coordinates in the format
  `"latitude,longitude"`.

- dest:

  Character string containing the destination coordinates in the format
  `"latitude,longitude"`.

- mode:

  Character. Travel mode accepted by the TomTom Routing API (e.g.,
  `"car"`, `"truck"`, `"pedestrian"`).

- dir:

  Character. Directory containing the hourly pollutant grid shapefiles.

- key:

  Character. TomTom API key.

- output:

  Character. Output type. Either `"df"` to return a data frame or
  `"plot"` to return an interactive `leaflet` map.

- hours:

  Character. Departure date and time in the format "YYYY-mm-dd
  HH:MM:SS".

- gridID:

  Character. Name of the grid identifier field.

- shapeValue:

  Character. Name of the pollutant concentration field in the grid.

- units:

  Character. Units of the pollutant concentration (e.g., `"µg/m³"`).

- pollutant:

  Character. Pollutant name used for map labels and legends.

## Value

If `output = "df"`, a data frame summarizing the selected alternative
routes and their associated travel metrics, pollutant concentrations and
exposure estimates.

If `output = "plot"`, an interactive `leaflet` map displaying the
pollutant grid together with the selected alternative routes.

## Details

The function identifies the fastest, shortest, least polluted, most
polluted, lowest exposure, and highest exposure routes. Results can be
returned either as a data frame or as an interactive map.

This function combines route information obtained from the TomTom
Routing API with hourly pollutant concentration grids. If the trip spans
multiple hourly grids, pollutant concentrations are averaged using
[`temporary_grid_search()`](https://flortames.github.io/AirExposure/reference/temporary_grid_search.md).
Exposure is estimated as the product of the average pollutant
concentration along each route and the travel time.

A valid TomTom API key and an active internet connection are required.

## Examples

``` r
if (FALSE) { # \dontrun{
routes <- alternative_trajectories(
  origin = "-31.4201,-64.1888",
  dest = "-31.4300,-64.2000",
  mode = "car",
  hours = "2019-08-01 08:00:00",
  key = "YOUR_API_KEY",
  dir = "path/to/grids",
  gridID = "ID",
  shapeValue = "PM25",
  pollutant = "PM2.5",
  units = "µg/m³",
  output = "df"
)
} # }
```
