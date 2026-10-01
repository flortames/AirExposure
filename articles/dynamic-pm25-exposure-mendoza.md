# Dynamic PM2.5 Exposure Assessment in Mendoza Metropolitan Area

## Introduction

Human exposure to air pollution is commonly estimated assuming that an
individual remains at a fixed location throughout the day, typically the
place of residence. Although this approach is simple to implement, it
does not account for daily mobility, activity locations, transportation
modes, or temporal variations in pollutant concentrations.

In reality, exposure is influenced by where people travel, how long they
remain at different locations, the characteristics of the routes they
use, and changes in air pollution levels throughout the day. As a
result, fixed-location approaches may overestimate or underestimate
actual personal exposure.

The AirExposure package implements a Dynamic Exposure Method (DEM) that
integrates mobility patterns, activity schedules, travel routes, and
hourly pollutant concentration grids to estimate daily exposure to air
pollution. For comparison purposes, the package also includes a
Fixed-Location-Based Method (FLBM), which assumes that an individual
remains at a single location for the entire day.

This vignette presents a complete workflow using hourly PM2.5
concentration grids for the Mendoza Metropolitan Area (Argentina). The
objective is to demonstrate how daily mobility can be incorporated into
exposure assessment and how the results compare with those obtained from
a traditional fixed-location approach.

The workflow includes:

- retrieving hourly pollutant concentration grids;
- estimating exposure using a fixed-location approach (FLBM);
- evaluating alternative travel routes;
- estimating exposure using a mobility-based approach (DEM); and
- comparing the results obtained from both methodologies.

## Study area

This case study focuses on the Mendoza Metropolitan Area, located in
western Argentina. Mendoza is one of the country’s largest urban
agglomerations and experiences substantial spatial and temporal
variability in air pollutant concentrations associated with traffic,
urban activities, and meteorological conditions.

Hourly PM2.5 concentration fields are used to represent the spatial and
temporal variability of air pollution across the study area. The example
presented in this vignette corresponds to 1 August 2019, for which a
separate pollutant grid is available for each hour of the day.

The use of hourly pollutant grids allows exposure estimates to account
for changes in PM2.5 concentrations throughout the day and across
different locations within the metropolitan area.

The methodology implemented in AirExposure and the Mendoza case study
are described in the publications listed in the References section.

## Data availability

The hourly PM2.5 concentration grids used in this vignette are publicly
available through Zenodo:

**Dataset DOI:** <https://doi.org/10.5281/zenodo.22797605>

The dataset contains 24 hourly PM2.5 concentration grids for the Mendoza
Metropolitan Area (Argentina). Each Shapefile represents the spatial
distribution of PM2.5 concentrations for a specific hour of the day.

Because the complete dataset is stored externally, users must download
and extract it before running the full workflow presented in this
vignette.

After extracting the dataset, define the directory containing the
Shapefiles:

``` r

grid_dir <- "path/to/Mendoza_PM25_2019-08-01"
```

The directory should contain one Shapefile for each hour of the study
day. The available files can be inspected using:

``` r

grid_files <- list.files(
  path = grid_dir,
  pattern = "\\.shp$",
  full.names = FALSE
)

length(grid_files)
head(grid_files)
```

## Retrieving hourly pollutant grids

AirExposure provides functions for retrieving pollutant grids associated
with specific dates and times.

The
[`hourly_grid()`](https://flortames.github.io/AirExposure/reference/hourly_grid.md)
function can be used to identify the file corresponding to a particular
hour.

``` r

hourly_grid(
  hour = "2019-08-01 08:00:00",
  time_format = "%Y-%m-%d %H:%M:%S",
  dir = grid_dir
)
```

When exposure spans several hours, the
[`temporary_grid_search()`](https://flortames.github.io/AirExposure/reference/temporary_grid_search.md)
function can be used to retrieve and average pollutant concentrations
across all required hourly grids.

For example, the following code retrieves the mean PM2.5 concentration
grid between 08:00 and 10:00.

``` r

grid <- temporary_grid_search(
  start_hour = "2019-08-01 08:00:00",
  end_hour = "2019-08-01 10:00:00",
  dir = grid_dir,
  time_format = "%Y-%m-%d %H:%M:%S",
  gridID = "ID",
  shapeValue = "value"
)
```

The resulting object is returned as an `sf` layer containing the mean
PM2.5 concentration estimated for each grid cell during the selected
time period.

The resulting grid contains 5,984 cells covering the Mendoza
Metropolitan Area. Most grid cells were classified within the “Good” AQI
category for the selected period, although localized areas with higher
PM2.5 concentrations were also identified. This spatial variability
illustrates the importance of incorporating location and mobility into
exposure assessments.

## Fixed-location exposure assessment (FLBM)

Traditional exposure assessment methods commonly assume that an
individual remains at a single location throughout the day, typically
the place of residence. This approach is referred to here as the
Fixed-Location-Based Method (FLBM).

In AirExposure, the FLBM is implemented through the
[`traditional_model()`](https://flortames.github.io/AirExposure/reference/traditional_model.md)
function. The method estimates exposure by identifying the grid cell
containing the origin location, calculating the average pollutant
concentration for the entire day, and assuming continuous exposure at
that location during a 24-hour period.

The following example estimates daily exposure for a residential
location in the Mendoza Metropolitan Area.

``` r

home_location <- data.frame(
  longitude = -68.8320,
  latitude = -32.9058
)

traditional_exposure <- traditional_model(
  origin_point = home_location,
  date = "2019-08-01",
  dir = grid_dir,
  gridID = "ID",
  shapeValue = "value"
)
```

Although this approach is widely used due to its simplicity, it does not
consider daily mobility, activity locations, route choice, or temporal
changes in pollutant concentrations associated with travel.

The Dynamic Exposure Method (DEM), presented in the following sections,
addresses these limitations by explicitly incorporating individual
mobility patterns into the exposure assessment process.

## Alternative route analysis

Alternative routes may differ in travel duration, distance, traffic
conditions, and pollutant concentrations.

AirExposure uses the TomTom Routing API to retrieve alternative routes
between an origin and a destination and combines these routes with
hourly pollutant concentration grids.

The
[`alternative_trajectories()`](https://flortames.github.io/AirExposure/reference/alternative_trajectories.md)
function compares the available routes according to several criteria,
including:

- shortest route;
- fastest route;
- least polluted route;
- most polluted route;
- lowest exposure route; and
- highest exposure route.

The example below illustrates how alternative routes can be evaluated
using the Mendoza PM2.5 dataset.

``` r

routes <- alternative_trajectories(
  origin = "-32.9058,-68.8320",
  dest = "-32.8705,-68.8320",
  mode = "car",
  hours = "2019-08-01 08:00:00",
  key = "YOUR_API_KEY",
  dir = grid_dir,
  gridID = "ID",
  shapeValue = "value",
  pollutant = "PM2.5",
  units = "ug/m3",
  output = "df"
)
```

The resulting object contains route-level summaries, including travel
time, distance, average pollutant concentration, and estimated exposure.

Route comparison is particularly important because the route with the
lowest pollutant concentration is not necessarily the route associated
with the lowest exposure. Exposure depends on both concentration levels
and travel duration.

This route-level assessment provides the basis for the Dynamic Exposure
Method (DEM) implemented in AirExposure and used in the following
sections.

## Dynamic exposure assessment (DEM)

The Dynamic Exposure Method (DEM) extends traditional exposure
assessment by incorporating daily mobility patterns, travel routes,
activity schedules, and hourly pollutant concentrations.

In AirExposure, the DEM is implemented through the
[`total_exposure()`](https://flortames.github.io/AirExposure/reference/total_exposure.md)
function. The method integrates:

- origin and destination locations;
- travel routes obtained from the TomTom Routing API;
- travel modes;
- activity durations;
- hourly pollutant concentration grids; and
- route selection criteria.

The example below represents a simplified daily schedule consisting of a
trip from home to an activity location, a period spent at that location,
and a return trip.

``` r

travel_list <- data.frame(
  long = c(-68.8320, -68.8320),
  lat = c(-32.9058, -32.8705)
)

activity_minutes <- data.frame(
  minutes = 300
)

daily_exposure <- total_exposure(
  travel_list = travel_list,
  mode = c("car", "car"),
  dir = grid_dir,
  key = "YOUR_API_KEY",
  selection = c("fast", "fast"),
  output_exp = "df",
  departure_time_home = "2019-08-01 08:00:00",
  activity_minutes = activity_minutes,
  pollutant = "PM2.5",
  shapeValue = "value",
  gridID = "ID",
  units = "ug/m3"
)
```

The resulting object contains estimates of exposure accumulated during
travel, exposure associated with activities at destination locations,
and total daily exposure.

By accounting for mobility and temporal changes in air pollution, the
DEM provides a more realistic representation of individual exposure than
fixed-location approaches.

## Conclusions

AirExposure provides a framework for integrating mobility information
with spatial and temporal variations in air pollution.

Using the Mendoza Metropolitan Area case study, this vignette
demonstrated how hourly PM2.5 concentration grids can be combined with
travel routes, activity schedules, and transportation modes to estimate
daily exposure.

The workflow presented in this vignette illustrates how AirExposure can
be used to:

- retrieve and aggregate hourly pollutant grids;
- estimate exposure using a fixed-location approach (FLBM);
- compare alternative travel routes;
- estimate exposure using a mobility-based approach (DEM); and
- calculate total daily exposure.

The Mendoza PM2.5 dataset used throughout this vignette is publicly
available through Zenodo and can be used to reproduce the analyses
presented here.

The comparison between fixed-location and mobility-based exposure
assessment highlights the importance of incorporating daily mobility
patterns into air pollution exposure studies.

## References

Tames, M.F., Puliafito, S.E., Urquiza, J. et al. Spatio-temporal
analysis of bicyclists’ PM2.5 exposure levels in a medium sized urban
agglomeration. Environ Monit Assess 196, 1194 (2024).
<https://doi.org/10.1007/s10661-024-13356-w>

Tames, M.F., Urquiza, J., Berná-Peña, L.L. et al. Modeling Influence of
Population Mobility to Airborne PM2.5 Exposure. Environ Model Assess 30,
1235–1251 (2025). <https://doi.org/10.1007/s10666-025-10050-0>

Tames, M.F. (2026). Hourly PM2.5 concentration grids for Mendoza
(Argentina) on 2019-08-01. Zenodo.
<https://doi.org/10.5281/zenodo.22797605>
