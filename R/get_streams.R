#' Retrieve a Strava data stream for a single activity
#' 
#' Retrieve a Strava data stream for a single activity.
#' Internally called by \code{\link{get_activity_streams}}.
#'
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' @param id numeric for id of the request
#' @param request chr string defining the stream type, must be "activities", "segment_efforts", "segments"
#' @param types list of chr strings with any combination of "time" (seconds), "latlng", "distance" (meters), "altitude" (meters), "velocity_smooth" (meters per second), "heartrate" (bpm), "cadence" (rpm), "watts", "temp" (degrees Celsius), "moving" (boolean), or "grade_smooth" (percent)
#' @param resolution chr string for the data resolution to retrieve, can be "low", "medium", "high", defaults to all
#' @param series_type chr string for merging the data if \code{resolution} is not equal to "all".  Accepted values are "distance" or "time". If omitted, no merging is performed.
#' 
#' @details Requires authentication stoken using the \code{\link{strava_oauth}} function and a user-created API on the strava website. From the API documentation, 'streams' is the Strava term for the raw data associated with an activity.
#' 
#' @return Data from an API request.
#' @export
#' @concept token
#' 
#' @import httr
#' 
#' @examples
#' \dontrun{
#' # create authentication token
#' # requires user created app name, id, and secret from Strava website
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, 
#' 	app_secret, cache = TRUE))
#' 
#' get_streams(stoken, id = 351217692, types = list('distance', 'latlng'))
#' }
get_streams  <- function(stoken, id, request = "activities",
												 types = NULL, resolution = NULL, series_type = NULL){

	if (length(id) != 1){
		stop('id must be a scalar.')
	}
	VALID_TYPES <- c("time", "latlng", "distance", "altitude", "velocity_smooth", "heartrate", "cadence", "watts", "temp", "moving", "grade_smooth")
	if(!is.null(types)) {
		types <- match.arg(types, VALID_TYPES)
	} else {
		types <- VALID_TYPES
	}
	
	req <- GET(url_streams(id, request, types), stoken,
						 query = list(resolution = resolution, series_type = series_type))
	ratelimit(req)
	stop_for_status(req)
	dataRaw <- content(req)
	
	return(dataRaw)
	
}

