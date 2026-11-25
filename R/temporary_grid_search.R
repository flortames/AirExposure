#' Retrieve Pollutant Grid(s) for a Given Time Period
#'
#' Retrieves the pollutant grid corresponding to a given date and time.
#' When a time interval spanning multiple hours is provided, the function
#' averages the pollutant values across all hourly grids and returns a
#' single grid.
#'
#' @param start_hour Start date and time. A `POSIXct` or `POSIXlt` object
#'   is recommended. Character values with an explicit time-zone offset
#'   may also be supplied.
#' @param end_hour Optional end date and time. If `NULL`, only the grid
#'   corresponding to `start_hour` is returned.
#' @param dir Character. Directory containing the hourly grid shapefiles.
#' @param grid_tz Character. Time zone represented by the hourly grid
#'   filenames, specified as an Olson time-zone name such as
#'   `"America/Argentina/Mendoza"`.
#' @param gridID Character. Name of the field containing the grid cell
#'   identifier.
#' @param shapeValue Character. Name of the field containing the pollutant
#'   concentration values.
#'
#' @details
#' If `start_hour` and `end_hour` span multiple hours, the function
#' retrieves every corresponding hourly grid, calculates the mean pollutant
#' concentration for each grid cell, and returns the resulting averaged
#' grid as an `sf` object.
#'
#' The returned object is always transformed to the WGS84 geographic
#' coordinate reference system (EPSG:4326).
#'
#' @return
#' An `sf` object containing the pollutant grid corresponding to the
#' requested hour or the average pollutant grid over the requested time
#' interval.
#'
#' @examples
#' \dontrun{
#' temporary_grid_search(
#'   start_hour = "2019-08-01 08:00:00",
#'   end_hour = "2019-08-01 10:00:00",
#'   dir = "path/to/grids",
#'   time_format = "%Y-%m-%d %H:%M:%S",
#'   gridID = "ID",
#'   shapeValue = "PM25"
#' )
#' }
#'
#' @export

temporary_grid_search <- function(
  start_hour,
  end_hour = NULL,
  dir,
  grid_tz,
  gridID,
  shapeValue
) {
  # Validate inputs

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
  
  if (!is.character(gridID) || length(gridID) != 1) {
    stop("'gridID' must be a single character value.")
  }

  if (!is.character(shapeValue) || length(shapeValue) != 1) {
    stop("'shapeValue' must be a single character value.")
  }

  # Normalize input times to UTC
  
  start_time_utc <- normalize_datetime(
    start_hour,
    arg = "start_hour"
  )
  
  if (is.null(end_hour)) {
    end_time_utc <- start_time_utc
  } else {
    end_time_utc <- normalize_datetime(
      end_hour,
      arg = "end_hour"
    )
    
    if (end_time_utc < start_time_utc) {
      stop(
        "'end_hour' must not be earlier than 'start_hour'.",
        call. = FALSE
      )
    }
  }
  
  # Convert UTC times to the time zone used by the pollutant grids
  
  start_time_grid <- lubridate::with_tz(
    start_time_utc,
    tzone = grid_tz
  )
  
  end_time_grid <- lubridate::with_tz(
    end_time_utc,
    tzone = grid_tz
  )
  
  # Generate every required local grid hour
  
  requested_hours <- seq(
    from = lubridate::floor_date(
      start_time_grid,
      unit = "hour"
    ),
    to = lubridate::floor_date(
      end_time_grid,
      unit = "hour"
    ),
    by = "hour"
  )

  grids <- vector("list", length(requested_hours))
  
  # Generate every required hour, including periods crossing midnight

  requested_hours <- seq(
    from = lubridate::floor_date(start_time_grid, unit = "hour"),
    to = lubridate::floor_date(end_time_grid, unit = "hour"),
    by = "hour"
  )

  grids <- vector("list", length(requested_hours))

  for (i in seq_along(requested_hours)) {
    hour_text <- format(
      requested_hours[i],
      format = "%Y-%m-%d %H:%M:%S"
    )

    grid_name <- hourly_grid(
      hour = hour_text,
      time_format = "%Y-%m-%d %H:%M:%S",
      dir = dir
    )

    grid_path <- file.path(dir, grid_name)

    grid <- sf::st_read(
      grid_path,
      quiet = TRUE
    )

    if (!gridID %in% names(grid)) {
      stop(
        paste0(
          "Column specified in 'gridID' was not found in ",
          grid_name,
          "."
        )
      )
    }

    if (!shapeValue %in% names(grid)) {
      stop(
        paste0(
          "Column specified in 'shapeValue' was not found in ",
          grid_name,
          "."
        )
      )
    }

    names(grid)[names(grid) == gridID] <- "ID"
    names(grid)[names(grid) == shapeValue] <- "value"

    grid <- sf::st_transform(grid, crs = 4326)

    grids[[i]] <- grid[, c("ID", "value")]
  }

  # A single requested grid requires no averaging

  if (length(grids) == 1) {
    return(grids[[1]])
  }

  # Combine grids and calculate the hourly mean for each cell

  combined_grid <- do.call(rbind, grids)

  output_grid <- combined_grid |>
    dplyr::group_by(.data$ID) |>
    dplyr::summarise(
      value = mean(.data$value, na.rm = TRUE),
      .groups = "drop"
    )

  return(output_grid)
}
