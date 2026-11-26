test_that("fails when directory does not exist", {
  hour <- lubridate::ymd_hms(
    "2019-08-01 11:00:00",
    tz = "UTC"
  )
  
  expect_error(
    hourly_grid(
      hour = hour,
      dir = "fake_directory",
      grid_tz = "America/Argentina/Mendoza"
    ),
    "does not exist"
  )
})

test_that("fails when grid_tz is not recognized", {
  hour <- lubridate::ymd_hms(
    "2019-08-01 11:00:00",
    tz = "UTC"
  )
  
  expect_error(
    hourly_grid(
      hour = hour,
      dir = tempdir(),
      grid_tz = "Mendoza"
    ),
    "recognized Olson time-zone name"
  )
})

test_that("fails when hour cannot be parsed", {
  expect_error(
    hourly_grid(
      hour = "not-a-dateZ",
      dir = tempdir(),
      grid_tz = "America/Argentina/Mendoza"
    ),
    "could not be parsed"
  )
})

test_that("hour must be a valid date-time input", {
  expect_error(
    hourly_grid(
      hour = 123,
      dir = tempdir(),
      grid_tz = "America/Argentina/Mendoza"
    ),
    "must be a POSIXct, POSIXlt, or character value"
  )
})

test_that("fails when no shapefiles are found", {
  temp_folder <- tempfile()
  dir.create(temp_folder)
  
  hour <- lubridate::ymd_hms(
    "2019-08-01 11:00:00",
    tz = "UTC"
  )
  
  expect_error(
    hourly_grid(
      hour = hour,
      dir = temp_folder,
      grid_tz = "America/Argentina/Mendoza"
    ),
    "No shapefiles were found"
  )
})

test_that("converts UTC to grid time zone and returns matching shapefile", {
  temp_folder <- tempfile()
  dir.create(temp_folder)
  
  file.create(
    file.path(
      temp_folder,
      "2019-08-01_0800.shp"
    )
  )
  
  hour <- lubridate::ymd_hms(
    "2019-08-01 11:00:00",
    tz = "UTC"
  )
  
  result <- hourly_grid(
    hour = hour,
    dir = temp_folder,
    grid_tz = "America/Argentina/Mendoza"
  )
  
  expect_equal(
    result,
    "2019-08-01_0800.shp"
  )
})

test_that("fails when no shapefile matches requested local hour", {
  temp_folder <- tempfile()
  dir.create(temp_folder)
  
  file.create(
    file.path(
      temp_folder,
      "2019-08-01_0900.shp"
    )
  )
  
  hour <- lubridate::ymd_hms(
    "2019-08-01 11:00:00",
    tz = "UTC"
  )
  
  expect_error(
    hourly_grid(
      hour = hour,
      dir = temp_folder,
      grid_tz = "America/Argentina/Mendoza"
    ),
    "No shapefile was found for the requested date and hour"
  )
})

test_that("grid selection does not depend on system time zone", {
  temp_folder <- tempfile()
  dir.create(temp_folder)
  
  file.create(
    file.path(
      temp_folder,
      "2019-08-01_0800.shp"
    )
  )
  
  hour <- lubridate::ymd_hms(
    "2019-08-01 11:00:00",
    tz = "UTC"
  )
  
  result_utc <- withr::with_timezone(
    "UTC",
    hourly_grid(
      hour = hour,
      dir = temp_folder,
      grid_tz = "America/Argentina/Mendoza"
    )
  )
  
  result_tokyo <- withr::with_timezone(
    "Asia/Tokyo",
    hourly_grid(
      hour = hour,
      dir = temp_folder,
      grid_tz = "America/Argentina/Mendoza"
    )
  )
  
  expect_equal(
    result_utc,
    "2019-08-01_0800.shp"
  )
  
  expect_equal(
    result_tokyo,
    "2019-08-01_0800.shp"
  )
  
  expect_equal(
    result_utc,
    result_tokyo
  )
})
