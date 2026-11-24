# Normalize date-time values to UTC
#
# Internal helper used to convert date-time inputs to POSIXct in UTC.
#
# @param x A character vector or a POSIXct/POSIXlt object.
# @param tz Optional character string indicating the time zone of character
#   values that do not contain an explicit offset.
# @param arg Character string used to identify the argument in error messages.
#
# @return A POSIXct object represented in UTC.
#
# @keywords internal

normalize_datetime <- function(
    x,
    tz = NULL,
    arg = "time"
) {
  if (inherits(x, "Date") && !inherits(x, "POSIXt")) {
    stop(
      paste0(
        "'", arg, "' must include both a date and a time."
      ),
      call. = FALSE
    )
  }
  
  if (inherits(x, "POSIXt")) {
    return(
      lubridate::with_tz(
        as.POSIXct(x),
        tzone = "UTC"
      )
    )
  }
  
  if (!is.character(x)) {
    stop(
      paste0(
        "'", arg,
        "' must be a POSIXct, POSIXlt, or character value."
      ),
      call. = FALSE
    )
  }
  
  if (length(x) == 0 || anyNA(x) || any(x == "")) {
    stop(
      paste0(
        "'", arg, "' must not be empty or NA."
      ),
      call. = FALSE
    )
  }
  
  has_explicit_zone <- grepl(
    "(Z|[+-][0-9]{2}:[0-9]{2})$",
    x
  )
  
  if (any(has_explicit_zone) && !all(has_explicit_zone)) {
    stop(
      paste0(
        "All values in '", arg,
        "' must use the same time-zone convention."
      ),
      call. = FALSE
    )
  }
  
  if (all(has_explicit_zone)) {
    parsed_time <- suppressWarnings(
      lubridate::ymd_hms(
        x,
        quiet = TRUE
      )
    )
  } else {
    if (
      is.null(tz) ||
      !is.character(tz) ||
      length(tz) != 1 ||
      is.na(tz) ||
      tz == ""
    ) {
      stop(
        paste0(
          "'", arg,
          "' has no explicit time-zone information. ",
          "Provide a time zone using 'tz'."
        ),
        call. = FALSE
      )
    }
    
    if (!tz %in% OlsonNames()) {
      stop(
        paste0(
          "'", tz,
          "' is not a recognized time-zone name."
        ),
        call. = FALSE
      )
    }
    
    parsed_time <- suppressWarnings(
      lubridate::ymd_hms(
        x,
        tz = tz,
        quiet = TRUE
      )
    )
  }
  
  if (anyNA(parsed_time)) {
    stop(
      paste0(
        "'", arg,
        "' could not be parsed as a date-time."
      ),
      call. = FALSE
    )
  }
  
  lubridate::with_tz(
    parsed_time,
    tzone = "UTC"
  )
}