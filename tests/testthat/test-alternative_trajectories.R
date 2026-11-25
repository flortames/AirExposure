fake_routes <- data.frame(
  ID = c(1, 2, 1, 2),

  long = c(
    -64.1888,
    -64.2000,
    -64.1888,
    -64.2100
  ),

  lat = c(
    -31.4201,
    -31.4300,
    -31.4201,
    -31.4400
  ),

  departureTime = as.POSIXct(
    c(
      "2019-08-01 11:00:00",
      "2019-08-01 11:00:00",
      "2019-08-01 11:00:00",
      "2019-08-01 11:00:00"
    ),
    tz = "UTC"
  ),
  
  arrivalTime = as.POSIXct(
    c(
      "2019-08-01 11:15:00",
      "2019-08-01 11:15:00",
      "2019-08-01 11:20:00",
      "2019-08-01 11:20:00"
    ),
    tz = "UTC"
  ),

  lengthInKM = c(10, 10, 12, 12),

  trafficLengthInKM = c(8, 8, 9, 9),

  travelMode = "car",

  trafficDelayInMinutes = c(2, 2, 3, 3),

  travelTimeInMinutes = c(15, 15, 20, 20),

  liveTrafficIncidentsTravelTimeInMinutes = c(
    17,
    17,
    23,
    23
  ),

  historicTrafficTravelTimeInMinutes = c(
    16,
    16,
    21,
    21
  ),

  noTrafficTravelTimeInMinutes = c(
    13,
    13,
    18,
    18
  ),

  alternative = c(
    "alternative_1",
    "alternative_1",
    "alternative_2",
    "alternative_2"
  )
)

fake_grid <- sf::st_sf(
  ID = 1,
  value = 10,
  geometry = sf::st_sfc(
    sf::st_polygon(list(rbind(
      c(-65, -32),
      c(-63, -32),
      c(-63, -30),
      c(-65, -30),
      c(-65, -32)
    ))),
    crs = 4326
  )
)

test_that("output must be either df or plot", {
  expect_error(
    alternative_trajectories(
      origin = "-32.79,-68.81",
      dest = "-32.90,-68.76",
      mode = "car",
      dir = "test",
      key = "fake",
      output = "table",
      gridID = "ID",
      shapeValue = "value",
      units = "ug/m3",
      pollutant = "PM2.5"
    ),
    "output"
  )
})

test_that("returns expected dataframe structure", {
  testthat::local_mocked_bindings(
    trajectories_tomtom = function(...) {
      fake_routes
    },

    temporary_grid_search = function(...) {
      fake_grid
    },

    .package = "AirExposure"
  )

  result <- alternative_trajectories(
    origin = "-31.4201,-64.1888",
    dest = "-31.4300,-64.2000",
    mode = "car",
    dir = tempdir(),
    key = "fake",
    output = "df",
    hours = "2019-08-01 08:00:00",
    gridID = "ID",
    shapeValue = "value",
    units = "ug/m3",
    pollutant = "PM2.5"
  )

  expect_s3_class(result, "data.frame")

  expect_true(
    all(
      c(
        "alternative",
        "daily_pol_value_mean",
        "exposure_value_mean",
        "type"
      ) %in%
        names(result)
    )
  )

  expect_true(
    all(result$daily_pol_value_mean >= 0)
  )

  expect_true(
    all(result$exposure_value_mean >= 0)
  )

  expect_true(
    all(
      result$type %in%
        c(
          "fast",
          "short",
          "morepol",
          "lesspol",
          "moreexpos",
          "lessexpos"
        )
    )
  )
})

test_that("returns a leaflet map when output is plot", {
  testthat::local_mocked_bindings(
    trajectories_tomtom = function(...) {
      fake_routes
    },
    temporary_grid_search = function(...) {
      fake_grid
    },
    .package = "AirExposure"
  )

  result <- alternative_trajectories(
    origin = "-31.4201,-64.1888",
    dest = "-31.4300,-64.2000",
    mode = "car",
    dir = tempdir(),
    key = "fake",
    output = "plot",
    hours = "2019-08-01 08:00:00",
    gridID = "ID",
    shapeValue = "value",
    units = "ug/m3",
    pollutant = "PM2.5"
  )

  expect_s3_class(result, "leaflet")
})

test_that("passes UTC times and grid time zone through the routing workflow", {
  testthat::local_mocked_bindings(
    trajectories_tomtom = function(
    origin,
    dest,
    mode,
    hour_trajectory,
    key,
    tz
    ) {
      expect_equal(
        tz,
        "America/Argentina/Mendoza"
      )
      
      expect_equal(
        hour_trajectory,
        "2019-08-01 08:00:00"
      )
      
      fake_routes
    },
    
    temporary_grid_search = function(
    start_hour,
    end_hour,
    dir,
    grid_tz,
    gridID,
    shapeValue
    ) {
      expect_s3_class(start_hour, "POSIXct")
      expect_s3_class(end_hour, "POSIXct")
      
      expect_equal(
        lubridate::tz(start_hour),
        "UTC"
      )
      
      expect_equal(
        lubridate::tz(end_hour),
        "UTC"
      )
      
      expect_equal(
        grid_tz,
        "America/Argentina/Mendoza"
      )
      
      fake_grid
    },
    
    .package = "AirExposure"
  )
  
  alternative_trajectories(
    origin = "-31.4201,-64.1888",
    dest = "-31.4300,-64.2000",
    mode = "car",
    dir = tempdir(),
    key = "fake",
    output = "df",
    hours = "2019-08-01 08:00:00",
    grid_tz = "America/Argentina/Mendoza",
    gridID = "ID",
    shapeValue = "value",
    units = "ug/m3",
    pollutant = "PM2.5"
  )
})

test_that("uses the latest arrival time across alternative routes", {
  routes_unordered <- fake_routes
  
  routes_unordered$arrivalTime <- as.POSIXct(
    c(
      "2019-08-01 11:15:00",
      "2019-08-01 11:15:00",
      "2019-08-01 11:25:00",
      "2019-08-01 11:20:00"
    ),
    tz = "UTC"
  )
  
  captured_end_hour <- NULL
  
  testthat::local_mocked_bindings(
    trajectories_tomtom = function(...) {
      routes_unordered
    },
    
    temporary_grid_search = function(
    start_hour,
    end_hour,
    dir,
    grid_tz,
    gridID,
    shapeValue
    ) {
      captured_end_hour <<- end_hour
      fake_grid
    },
    
    .package = "AirExposure"
  )
  
  alternative_trajectories(
    origin = "-31.4201,-64.1888",
    dest = "-31.4300,-64.2000",
    mode = "car",
    dir = tempdir(),
    key = "fake",
    output = "df",
    hours = "2019-08-01 08:00:00",
    grid_tz = "America/Argentina/Mendoza",
    gridID = "ID",
    shapeValue = "value",
    units = "ug/m3",
    pollutant = "PM2.5"
  )
  
  expect_equal(
    captured_end_hour,
    as.POSIXct(
      "2019-08-01 11:25:00",
      tz = "UTC"
    )
  )
})
