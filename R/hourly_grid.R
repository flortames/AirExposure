#' Retrieve the Hourly Grid File for a Given Date and Time
#'
#' Searches a directory containing hourly pollutant grid shapefiles and
#' returns the filename corresponding to the requested date and hour.
#'
#' @param hour Date and time used to identify the grid file. A `POSIXct` or
#'   `POSIXlt` object is recommended. Character values with an explicit
#'   time-zone offset may also be supplied.
#' @param dir Character. Directory containing the hourly grid shapefiles.
#' @param grid_tz Character. Time zone represented by the hourly grid
#'   filenames, specified as an Olson time-zone name such as
#'   `"America/Argentina/Mendoza"`.
#'
#' @details
#' Hourly grid shapefiles are expected to follow the naming convention
#' `"YYYY-mm-dd_HHMM.shp"`.
#'
#' @return
#' A character string containing the name of the matching shapefile.
#'
#' @examples
#' \dontrun{
#' hourly_grid(
#'   hour = "2019-08-01 08:00:00",
#'   time_format = "%Y-%m-%d %H:%M:%S",
#'   dir = "path/to/grids"
#' )
#' }
#'
#' @export

hourly_grid <- function(hour, dir, grid_tz) {
  if (!dir.exists(dir)) {
    stop("Directory specified in 'dir' does not exist.")
  }
  if (
    !is.character(grid_tz) ||
    length(grid_tz) != 1 ||
    is.na(grid_tz) ||
    grid_tz == "" ||
    !grid_tz %in% OlsonNames()
  ) {
    stop(
      "'grid_tz' must be a recognized Olson time-zone name.",
      call. = FALSE
    )
  }

  input_hour_utc <- normalize_datetime(
    hour,
    arg = "hour"
  )
  
  input_hour_grid <- lubridate::with_tz(
    input_hour_utc,
    tzone = grid_tz
  )
  
  hour_exposure <- lubridate::hour(input_hour_grid)
  exposure_day <- lubridate::date(input_hour_grid)

  # List available shapefiles

  file_list <- list.files(
    path = dir,
    pattern = "\\.shp$",
    full.names = FALSE
  )

  if (length(file_list) == 0) {
    stop("No shapefiles were found in 'dir'.")
  }

  # Shapefile names must follow the format YYYY-mm-dd_HHMM.shp

  table_files <- as.POSIXct(
    strptime(
      substr(file_list, 1, 15),
      format = "%Y-%m-%d_%H%M"
    )
  )

  searched_date <- which(
    lubridate::date(table_files) == exposure_day
  )

  table_files <- table_files[searched_date]

  searched_hour <- which(
    lubridate::hour(table_files) == hour_exposure
  )

  if (length(searched_hour) == 0) {
    stop(
      "No shapefile was found for the requested date and hour."
    )
  }

  file <- table_files[searched_hour]

  name_file <- paste(
    substr(file, 1, 10),
    "_",
    substr(file, 12, 13),
    substr(file, 15, 16),
    ".shp",
    sep = ""
  )

  return(name_file)
}
