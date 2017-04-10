#' Explore segments within a bounded area
#' 
#' Explore segments within a bounded area
#'
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' @param bounds chr string representing the comma separated list of bounding box corners 'sw.lat,sw.lng,ne.lat,ne.lng' or 'south, west, north, east', see the example
#' @param activity_type chr string indicating activity type, "riding" or "running"
#' @param max_cat numeric indicating the maximum climbing category
#' @param min_cat numeric indicating the minimum climbing category
#' 
#' @details Requires authentication stoken using the \code{\link{strava_oauth}} function and a user-created API on the strava website.
#' 
#' @return Data from an API request.
#' 
#' @concept token
#' 
#' @export
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
#' bnds <- "37.821362, -122.505373, 37.842038, -122.465977"
#' get_explore(stoken, bnds)
#' }
get_explore <- function(stoken, bounds, activity_type="riding", max_cat=NULL, min_cat=NULL){

	url_ <- url_segment(request="explore")
	dataRaw <- get_basic(url_, stoken, queries=list(bounds=bounds,
																									activity_type=activity_type,
																									max_cat=max_cat,
																									min_cat=min_cat))
	return(dataRaw)
	
}
