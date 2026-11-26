test_that("fails when directory does not exist", {
  start_time <- lubridate::ymd_hms(
    "2019-08-01 11:00:00",
    tz = "UTC"
  )
  
  expect_error(
    temporary_grid_search(
      start_hour = start_time,
      dir = "fake_directory",
      grid_tz = "America/Argentina/Mendoza",
      gridID = "ID",
      shapeValue = "value"
    ),
    "does not exist"
  )
})

test_that("fails when grid_tz is not recognized", {
  start_time <- lubridate::ymd_hms(
    "2019-08-01 11:00:00",
    tz = "UTC"
  )
  
  expect_error(
    temporary_grid_search(
      start_hour = start_time,
      dir = tempdir(),
      grid_tz = "Mendoza",
      gridID = "ID",
      shapeValue = "value"
    ),
    "recognized Olson time-zone name"
  )
})

test_that("fails when start_hour cannot be parsed", {
  expect_error(
    temporary_grid_search(
      start_hour = "not-a-dateZ",
      dir = tempdir(),
      grid_tz = "America/Argentina/Mendoza",
      gridID = "ID",
      shapeValue = "value"
    ),
    "start_hour.*could not be parsed"
  )
})

test_that("fails when end_hour cannot be parsed", {
  start_time <- lubridate::ymd_hms(
    "2019-08-01 11:00:00",
    tz = "UTC"
  )
  
  expect_error(
    temporary_grid_search(
      start_hour = start_time,
      end_hour = "not-a-dateZ",
      dir = tempdir(),
      grid_tz = "America/Argentina/Mendoza",
      gridID = "ID",
      shapeValue = "value"
    ),
    "end_hour.*could not be parsed"
  )
})

test_that("fails when end_hour is earlier than start_hour", {
  start_time <- lubridate::ymd_hms(
    "2019-08-01 13:00:00",
    tz = "UTC"
  )
  
  end_time <- lubridate::ymd_hms(
    "2019-08-01 11:00:00",
    tz = "UTC"
  )
  
  expect_error(
    temporary_grid_search(
      start_hour = start_time,
      end_hour = end_time,
      dir = tempdir(),
      grid_tz = "America/Argentina/Mendoza",
      gridID = "ID",
      shapeValue = "value"
    ),
    "earlier than"
  )
})

test_that("gridID must be a single character value", {
  start_time <- lubridate::ymd_hms(
    "2019-08-01 11:00:00",
    tz = "UTC"
  )
  
  expect_error(
    temporary_grid_search(
      start_hour = start_time,
      dir = tempdir(),
      grid_tz = "America/Argentina/Mendoza",
      gridID = 123,
      shapeValue = "value"
    ),
    "gridID"
  )
})

test_that("shapeValue must be a single character value", {
  start_time <- lubridate::ymd_hms(
    "2019-08-01 11:00:00",
    tz = "UTC"
  )
  
  expect_error(
    temporary_grid_search(
      start_hour = start_time,
      dir = tempdir(),
      grid_tz = "America/Argentina/Mendoza",
      gridID = "ID",
      shapeValue = 123
    ),
    "shapeValue"
  )
})

test_that("returns the corresponding local grid for a UTC instant", {
  temp_folder <- tempfile()
  dir.create(temp_folder)
  
  grid <- sf::st_as_sf(
    data.frame(
      ID = 1,
      value = 100,
      lon = -64,
      lat = -31
    ),
    coords = c("lon", "lat"),
    crs = 4326
  )
  
  sf::st_write(
    grid,
    file.path(
      temp_folder,
      "2019-08-01_0800.shp"
    ),
    delete_layer = TRUE,
    quiet = TRUE
  )
  
  start_time <- lubridate::ymd_hms(
    "2019-08-01 11:00:00",
    tz = "UTC"
  )
  
  result <- temporary_grid_search(
    start_hour = start_time,
    dir = temp_folder,
    grid_tz = "America/Argentina/Mendoza",
    gridID = "ID",
    shapeValue = "value"
  )
  
  expect_s3_class(result, "sf")
  expect_equal(result$ID, 1)
  expect_equal(result$value, 100)
})

test_that("averages pollutant values across multiple local grid hours", {
  temp_folder <- tempfile()
  dir.create(temp_folder)
  
  grid1 <- sf::st_as_sf(
    data.frame(
      ID = 1,
      value = 10,
      lon = -64,
      lat = -31
    ),
    coords = c("lon", "lat"),
    crs = 4326
  )
  
  grid2 <- sf::st_as_sf(
    data.frame(
      ID = 1,
      value = 20,
      lon = -64,
      lat = -31
    ),
    coords = c("lon", "lat"),
    crs = 4326
  )
  
  sf::st_write(
    grid1,
    file.path(
      temp_folder,
      "2019-08-01_0800.shp"
    ),
    delete_layer = TRUE,
    quiet = TRUE
  )
  
  sf::st_write(
    grid2,
    file.path(
      temp_folder,
      "2019-08-01_0900.shp"
    ),
    delete_layer = TRUE,
    quiet = TRUE
  )
  
  start_time <- lubridate::ymd_hms(
    "2019-08-01 11:00:00",
    tz = "UTC"
  )
  
  end_time <- lubridate::ymd_hms(
    "2019-08-01 12:00:00",
    tz = "UTC"
  )
  
  result <- temporary_grid_search(
    start_hour = start_time,
    end_hour = end_time,
    dir = temp_folder,
    grid_tz = "America/Argentina/Mendoza",
    gridID = "ID",
    shapeValue = "value"
  )
  
  expect_s3_class(result, "sf")
  expect_equal(result$ID, 1)
  expect_equal(result$value, 15)
})

test_that("fails when gridID column is not found", {
  temp_folder <- tempfile()
  dir.create(temp_folder)
  
  grid <- sf::st_as_sf(
    data.frame(
      wrong_ID = 1,
      value = 100,
      lon = -64,
      lat = -31
    ),
    coords = c("lon", "lat"),
    crs = 4326
  )
  
  sf::st_write(
    grid,
    file.path(
      temp_folder,
      "2019-08-01_0800.shp"
    ),
    delete_layer = TRUE,
    quiet = TRUE
  )
  
  start_time <- lubridate::ymd_hms(
    "2019-08-01 11:00:00",
    tz = "UTC"
  )
  
  expect_error(
    temporary_grid_search(
      start_hour = start_time,
      dir = temp_folder,
      grid_tz = "America/Argentina/Mendoza",
      gridID = "ID",
      shapeValue = "value"
    ),
    "gridID"
  )
})

test_that("fails when shapeValue column is not found", {
  temp_folder <- tempfile()
  dir.create(temp_folder)
  
  grid <- sf::st_as_sf(
    data.frame(
      ID = 1,
      wrongval = 100,
      lon = -64,
      lat = -31
    ),
    coords = c("lon", "lat"),
    crs = 4326
  )
  
  sf::st_write(
    grid,
    file.path(
      temp_folder,
      "2019-08-01_0800.shp"
    ),
    delete_layer = TRUE,
    quiet = TRUE
  )
  
  start_time <- lubridate::ymd_hms(
    "2019-08-01 11:00:00",
    tz = "UTC"
  )
  
  expect_error(
    temporary_grid_search(
      start_hour = start_time,
      dir = temp_folder,
      grid_tz = "America/Argentina/Mendoza",
      gridID = "ID",
      shapeValue = "value"
    ),
    "shapeValue"
  )
})

test_that("retrieves grids when an interval crosses an hour boundary", {
  temp_folder <- tempfile()
  dir.create(temp_folder)
  
  grid1 <- sf::st_as_sf(
    data.frame(
      ID = 1,
      value = 10,
      lon = -64,
      lat = -31
    ),
    coords = c("lon", "lat"),
    crs = 4326
  )
  
  grid2 <- sf::st_as_sf(
    data.frame(
      ID = 1,
      value = 20,
      lon = -64,
      lat = -31
    ),
    coords = c("lon", "lat"),
    crs = 4326
  )
  
  sf::st_write(
    grid1,
    file.path(temp_folder, "2019-08-01_0800.shp"),
    delete_layer = TRUE,
    quiet = TRUE
  )
  
  sf::st_write(
    grid2,
    file.path(temp_folder, "2019-08-01_0900.shp"),
    delete_layer = TRUE,
    quiet = TRUE
  )
  
  start_time <- lubridate::ymd_hms(
    "2019-08-01 11:55:00",
    tz = "UTC"
  )
  
  end_time <- lubridate::ymd_hms(
    "2019-08-01 12:17:00",
    tz = "UTC"
  )
  
  result <- temporary_grid_search(
    start_hour = start_time,
    end_hour = end_time,
    dir = temp_folder,
    grid_tz = "America/Argentina/Mendoza",
    gridID = "ID",
    shapeValue = "value"
  )
  
  expect_s3_class(result, "sf")
  expect_equal(result$value, 15)
})

test_that("retrieves grids when an interval crosses midnight", {
  temp_folder <- tempfile()
  dir.create(temp_folder)
  
  grid1 <- sf::st_as_sf(
    data.frame(
      ID = 1,
      value = 10,
      lon = -64,
      lat = -31
    ),
    coords = c("lon", "lat"),
    crs = 4326
  )
  
  grid2 <- sf::st_as_sf(
    data.frame(
      ID = 1,
      value = 20,
      lon = -64,
      lat = -31
    ),
    coords = c("lon", "lat"),
    crs = 4326
  )
  
  sf::st_write(
    grid1,
    file.path(temp_folder, "2019-08-01_2300.shp"),
    delete_layer = TRUE,
    quiet = TRUE
  )
  
  sf::st_write(
    grid2,
    file.path(temp_folder, "2019-08-02_0000.shp"),
    delete_layer = TRUE,
    quiet = TRUE
  )
  
  start_time <- lubridate::ymd_hms(
    "2019-08-02 02:50:00",
    tz = "UTC"
  )
  
  end_time <- lubridate::ymd_hms(
    "2019-08-02 03:20:00",
    tz = "UTC"
  )
  
  result <- temporary_grid_search(
    start_hour = start_time,
    end_hour = end_time,
    dir = temp_folder,
    grid_tz = "America/Argentina/Mendoza",
    gridID = "ID",
    shapeValue = "value"
  )
  
  expect_s3_class(result, "sf")
  expect_equal(result$value, 15)
})
