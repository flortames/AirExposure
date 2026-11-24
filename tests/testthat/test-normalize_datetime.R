test_that("POSIXct values are represented in UTC", {
  input_time <- lubridate::ymd_hms(
    "2019-08-01 08:00:00",
    tz = "America/Argentina/Mendoza"
  )
  
  result <- AirExposure:::normalize_datetime(input_time)
  
  expect_s3_class(result, "POSIXct")
  expect_equal(
    format(result, tz = "UTC"),
    "2019-08-01 11:00:00"
  )
  expect_equal(
    lubridate::tz(result),
    "UTC"
  )
})

test_that("RFC 3339 values with an offset are parsed", {
  result <- AirExposure:::normalize_datetime(
    "2019-08-01T08:00:00-03:00"
  )
  
  expect_equal(
    format(result, tz = "UTC"),
    "2019-08-01 11:00:00"
  )
})

test_that("RFC 3339 values ending in Z are parsed", {
  result <- AirExposure:::normalize_datetime(
    "2019-08-01T11:00:00Z"
  )
  
  expect_equal(
    format(result, tz = "UTC"),
    "2019-08-01 11:00:00"
  )
})

test_that("local character values require a time zone", {
  expect_error(
    AirExposure:::normalize_datetime(
      "2019-08-01 08:00:00"
    ),
    "no explicit time-zone information"
  )
})

test_that("local character values use the supplied time zone", {
  result <- AirExposure:::normalize_datetime(
    "2019-08-01 08:00:00",
    tz = "America/Argentina/Mendoza"
  )
  
  expect_equal(
    format(result, tz = "UTC"),
    "2019-08-01 11:00:00"
  )
})

test_that("invalid time-zone names are rejected", {
  expect_error(
    AirExposure:::normalize_datetime(
      "2019-08-01 08:00:00",
      tz = "Mendoza"
    ),
    "not a recognized time-zone name"
  )
})

test_that("Date values are rejected", {
  expect_error(
    AirExposure:::normalize_datetime(
      as.Date("2019-08-01")
    ),
    "must include both a date and a time"
  )
})

test_that("invalid date-time strings are rejected", {
  expect_error(
    AirExposure:::normalize_datetime(
      "not-a-date",
      tz = "UTC"
    ),
    "could not be parsed"
  )
})
