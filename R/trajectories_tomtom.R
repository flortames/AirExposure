#' Retrieve Alternative Routes from the TomTom Routing API
#'
#' Retrieves up to five alternative routes between an origin and destination
#' using the TomTom Routing API. The function returns the route geometry as
#' point coordinates together with travel time, distance, and traffic-related
#' metrics for each alternative route.
#'
#' @param origin Character string containing the origin coordinates in the
#'   format `"latitude,longitude"`.
#' @param dest Character string containing the destination coordinates in the
#'   format `"latitude,longitude"`.
#' @param mode Character. Travel mode accepted by the TomTom Routing API.
#'   Supported values are `"car"`, `"truck"`, `"pedestrian"`, `"bicycle"`
#'   and `"motorcycle"`.
#' @param hour_trajectory Departure date and time. A `POSIXct` or `POSIXlt`
#'   object is recommended. Character values may also be supplied in RFC 3339
#'   format with an explicit offset, such as
#'   `"2019-08-01T08:00:00-03:00"`. Character values without an explicit
#'   offset require `tz`.
#' @param tz Optional character. Time-zone name used to interpret character
#'   values in `hour_trajectory` that do not include an explicit offset,
#'   for example `"America/Argentina/Mendoza"`.
#' @param key Character. Valid TomTom Routing API key.
#'
#' @details
#' This function requires a valid TomTom API key and an active internet
#' connection. Origin and destination coordinates must be supplied as
#' latitude-longitude pairs using the EPSG:4326 coordinate reference system.
#'
#' The output includes one row for each point along each alternative route
#' returned by the API.
#'
#' @return
#' A data frame with one row per route point and the following variables:
#' \describe{
#'   \item{ID}{Sequential point identifier within each route.}
#'   \item{long}{Longitude of the route point.}
#'   \item{lat}{Latitude of the route point.}
#'   \item{departureTime}{Departure time returned by the API.}
#'   \item{arrivalTime}{Arrival time returned by the API.}
#'   \item{lengthInKM}{Route length in kilometers.}
#'   \item{trafficLengthInKM}{Length affected by traffic in kilometers.}
#'   \item{travelMode}{Travel mode used for routing.}
#'   \item{trafficDelayInMinutes}{Estimated traffic delay in minutes.}
#'   \item{travelTimeInMinutes}{Estimated travel time in minutes.}
#'   \item{liveTrafficIncidentsTravelTimeInMinutes}{Travel time considering
#'   live traffic incidents.}
#'   \item{historicTrafficTravelTimeInMinutes}{Travel time estimated from
#'   historical traffic conditions.}
#'   \item{noTrafficTravelTimeInMinutes}{Estimated travel time assuming no
#'   traffic.}
#'   \item{alternative}{Alternative route identifier.}
#' }
#'
#' @examples
#' \dontrun{
#' routes <- trajectories_tomtom(
#'   origin = "-31.4201,-64.1888",
#'   dest = "-31.4300,-64.2000",
#'   mode = "car",
#'   hour_trajectory = "2019-08-01 08:00:00",
#'   key = Sys.getenv("TOMTOM_KEY"),
#'   tz = "America/Argentina/Cordoba"
#' )
#'
#' @export

trajectories_tomtom <- function(
  origin,
  dest,
  mode,
  hour_trajectory,
  key,
  tz = NULL
) {
  if (missing(origin) || missing(dest)) {
    stop("'origin' and 'dest' must be provided.")
  }

  if (!is.character(origin) || length(origin) != 1) {
    stop("'origin' must be a character string.")
  }

  if (!is.character(dest) || length(dest) != 1) {
    stop("'dest' must be a character string.")
  }

  if (
    missing(key) ||
      !is.character(key) ||
      length(key) != 1 ||
      is.na(key) ||
      key == ""
  ) {
    stop("A valid TomTom API key must be provided.")
  }

  coordinate_pattern <- "^-?[0-9]+(?:\\.[0-9]+)?,-?[0-9]+(?:\\.[0-9]+)?$"

  if (!grepl(coordinate_pattern, origin)) {
    stop("'origin' must be in the format 'latitude,longitude'.")
  }

  if (!grepl(coordinate_pattern, dest)) {
    stop("'dest' must be in the format 'latitude,longitude'.")
  }

  valid_modes <- c(
    "car",
    "truck",
    "pedestrian",
    "bicycle",
    "motorcycle"
  )

  if (
    !is.character(mode) ||
      length(mode) != 1 ||
      is.na(mode) ||
      !mode %in% valid_modes
  ) {
    stop(
      "'mode' must be one of: car, truck, pedestrian, bicycle, motorcycle."
    )
  }

  num_alternative <- 5
  
  if (length(hour_trajectory) != 1) {
    stop(
      "'hour_trajectory' must contain exactly one date-time value.",
      call. = FALSE
    )
  }
  
  departure_time_utc <- normalize_datetime(
    hour_trajectory,
    tz = tz,
    arg = "hour_trajectory"
  )
  
  departure_time_rfc3339 <- format(
    departure_time_utc,
    format = "%Y-%m-%dT%H:%M:%SZ",
    tz = "UTC"
  )
  
  hour_format <- utils::URLencode(
    departure_time_rfc3339,
    reserved = TRUE
  )

  origin_lat <- strsplit(origin, ",")[[1]][1]
  origin_long <- strsplit(origin, ",")[[1]][2]

  destination_lat <- strsplit(dest, ",")[[1]][1]
  destination_long <- strsplit(dest, ",")[[1]][2]

  url <- paste0(
    "https://api.tomtom.com/routing/1/calculateRoute/",
    origin_lat,
    "%2C",
    origin_long,
    "%3A",
    destination_lat,
    "%2C",
    destination_long,
    "/json?maxAlternatives=",
    num_alternative,
    "&departAt=",
    hour_format,
    "&routeRepresentation=polyline",
    "&computeTravelTimeFor=all",
    "&traffic=true",
    "&travelMode=",
    mode,
    "&vehicleEngineType=combustion",
    "&key=",
    key
  )

  # API request

  response <- httr::GET(url)

  httr::stop_for_status(response)

  resp_json <- jsonlite::fromJSON(
    httr::content(
      response,
      as = "text",
      encoding = "UTF-8"
    )
  )

  if (length(resp_json$routes) == 0) {
    stop("TomTom API returned no routes.")
  }

  df_rbind <- data.frame()
  df_rbind_output <- data.frame()

  for (j in seq_along(resp_json[["routes"]][["legs"]])) {
    resp <- data.frame(
      long = resp_json[["routes"]][["legs"]][[j]][["points"]][[1]][[
        "longitude"
      ]],

      lat = resp_json[["routes"]][["legs"]][[j]][["points"]][[1]][["latitude"]],

      departureTime = resp_json[["routes"]][["legs"]][[j]][["summary"]][[
        "departureTime"
      ]],

      arrivalTime = resp_json[["routes"]][["legs"]][[j]][["summary"]][[
        "arrivalTime"
      ]],

      lengthInKM = resp_json[["routes"]][["legs"]][[j]][["summary"]][[
        "lengthInMeters"
      ]] /
        1000,

      trafficLengthInKM = resp_json[["routes"]][["legs"]][[j]][["summary"]][[
        "trafficLengthInMeters"
      ]] /
        1000,

      travelMode = resp_json[["routes"]][["sections"]][[1]][["travelMode"]][1],

      trafficDelayInMinutes = round(
        resp_json[["routes"]][["legs"]][[j]][["summary"]][[
          "trafficDelayInSeconds"
        ]] /
          60,
        2
      ),

      travelTimeInMinutes = round(
        resp_json[["routes"]][["legs"]][[j]][["summary"]][[
          "travelTimeInSeconds"
        ]] /
          60,
        2
      ),

      liveTrafficIncidentsTravelTimeInMinutes = round(
        resp_json[["routes"]][["legs"]][[j]][["summary"]][[
          "liveTrafficIncidentsTravelTimeInSeconds"
        ]] /
          60,
        2
      ),

      historicTrafficTravelTimeInMinutes = round(
        resp_json[["routes"]][["legs"]][[j]][["summary"]][[
          "historicTrafficTravelTimeInSeconds"
        ]] /
          60,
        2
      ),

      noTrafficTravelTimeInMinutes = round(
        resp_json[["routes"]][["legs"]][[j]][["summary"]][[
          "noTrafficTravelTimeInSeconds"
        ]] /
          60,
        2
      ),

      alternative = paste0("alternative_", j)
    )

    ID <- seq_len(nrow(resp))

    data_frame_resp <- cbind(ID, resp)

    df_rbind <- rbind(df_rbind, data_frame_resp)
  }

  df_rbind_output <- rbind(df_rbind_output, df_rbind)

  names(df_rbind_output) <- c(
    "ID",
    "long",
    "lat",
    "departureTime",
    "arrivalTime",
    "lengthInKM",
    "trafficLengthInKM",
    "travelMode",
    "trafficDelayInMinutes",
    "travelTimeInMinutes",
    "liveTrafficIncidentsTravelTimeInMinutes",
    "historicTrafficTravelTimeInMinutes",
    "noTrafficTravelTimeInMinutes",
    "alternative"
  )

  df_rbind_output$departureTime <- normalize_datetime(
    df_rbind_output$departureTime,
    arg = "departureTime returned by TomTom"
  )
  
  df_rbind_output$arrivalTime <- normalize_datetime(
    df_rbind_output$arrivalTime,
    arg = "arrivalTime returned by TomTom"
  )
  
  return(df_rbind_output)
}
