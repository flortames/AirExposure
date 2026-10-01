# Estimate total daily exposure to an air pollutant

Estimates an individual's total daily exposure to an air pollutant by
combining exposure during trips, exposure at destinations, and exposure
at the home location. Travel routes are obtained from the TomTom Routing
API, while pollutant concentrations are extracted from hourly grid
shapefiles.

## Usage

``` r
total_exposure(
  travel_list,
  mode,
  dir,
  key,
  selection,
  output_exp,
  departure_time_home,
  activity_minutes,
  pollutant,
  shapeValue,
  gridID,
  units
)
```

## Arguments

- travel_list:

  Data frame containing the sequence of locations visited during the
  day. It must contain `latitude` and `longitude` columns. The first
  location is assumed to be the home location and the final trip always
  returns to this point.

- mode:

  Character vector indicating the travel mode for each trip (for example
  `"car"`, `"pedestrian"` or `"bicycle"`).

- dir:

  Character. Working directory containing the pollutant grids and
  temporary files.

- key:

  Character. TomTom API key.

- selection:

  Integer or character vector indicating which alternative route is
  selected for each trip.

- output_exp:

  Character. Output type. One of `"df"`, `"plot"` or `"polyline"`.

- departure_time_home:

  Character. Departure date and time from the home location.

- activity_minutes:

  Numeric vector indicating the duration (minutes) of the activity
  performed at each destination.

- pollutant:

  Character. Pollutant name used for map classification (for example
  `"PM2.5"`).

- shapeValue:

  Character. Name of the pollutant concentration field in the grid
  shapefiles.

- gridID:

  Character. Name of the grid identifier field.

- units:

  Character. Pollutant concentration units displayed in the map.

## Value

Depending on `output_exp`:

- `"df"`:

  A data frame summarizing exposure for each trip and the total daily
  exposure.

- `"plot"`:

  An interactive `leaflet` map showing the selected routes, visited
  locations and pollutant concentrations.

- `"polyline"`:

  An `sf` object containing the route polylines.

## Details

The function performs the following steps:

- Retrieves alternative routes between consecutive locations using the
  TomTom Routing API.

- Selects one route for each trip according to `selection`.

- Estimates exposure during travel using the selected route.

- Estimates exposure while remaining at each destination.

- Estimates exposure at the home location before the first trip.

- Calculates total daily exposure.

- Optionally returns an interactive map showing routes and pollutant
  concentrations.

This function relies on the helper functions
[`alternative_trajectories()`](https://flortames.github.io/AirExposure/reference/alternative_trajectories.md),
[`temporary_grid_search()`](https://flortames.github.io/AirExposure/reference/temporary_grid_search.md),
[`points_to_line()`](https://flortames.github.io/AirExposure/reference/points_to_line.md),
[`map_colors()`](https://flortames.github.io/AirExposure/reference/map_colors.md),
and
[`function_hours()`](https://flortames.github.io/AirExposure/reference/function_hours.md).

## Examples

``` r
if (FALSE) { # \dontrun{
exposure <- total_exposure(
  travel_list = travel_list,
  mode = c("car", "pedestrian"),
  dir = data_dir,
  key = api_key,
  selection = c(1, 1),
  output_exp = "plot",
  departure_time_home = "2019-08-01 08:00:00",
  activity_minutes = c(480),
  pollutant = "PM2.5",
  shapeValue = "value",
  gridID = "ID",
  units = expression(mu * g/m^3)
)
} # }
```
