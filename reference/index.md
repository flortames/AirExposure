# Package index

## Pollutant grids

Functions for creating, locating, processing, and classifying pollutant
grids.

- [`make_grid()`](https://flortames.github.io/AirExposure/reference/make_grid.md)
  : Create example hourly pollutant grids
- [`hourly_grid()`](https://flortames.github.io/AirExposure/reference/hourly_grid.md)
  : Retrieve the Hourly Grid File for a Given Date and Time
- [`temporary_grid_search()`](https://flortames.github.io/AirExposure/reference/temporary_grid_search.md)
  : Retrieve Pollutant Grid(s) for a Given Time Period
- [`map_colors()`](https://flortames.github.io/AirExposure/reference/map_colors.md)
  : Assign AQI categories and colors to a pollutant grid

## Routes and mobility

Functions for constructing and comparing travel routes.

- [`points_to_line()`](https://flortames.github.io/AirExposure/reference/points_to_line.md)
  : Convert Points to LINESTRING Geometries
- [`trajectories_tomtom()`](https://flortames.github.io/AirExposure/reference/trajectories_tomtom.md)
  : Retrieve Alternative Routes from the TomTom Routing API
- [`alternative_trajectories()`](https://flortames.github.io/AirExposure/reference/alternative_trajectories.md)
  : Compare alternative travel routes using pollutant concentrations

## Exposure assessment

Functions for estimating fixed-location and mobility-based exposure.

- [`traditional_model()`](https://flortames.github.io/AirExposure/reference/traditional_model.md)
  : Estimate Daily Exposure Using the Traditional Model
- [`total_exposure()`](https://flortames.github.io/AirExposure/reference/total_exposure.md)
  : Estimate total daily exposure to an air pollutant

## Utilities

Supporting functions used in exposure workflows.

- [`function_hours()`](https://flortames.github.io/AirExposure/reference/function_hours.md)
  : Convert minutes to HH:MM format
