#' Get detailed data of an activity
#' 
#' Get detailed data of an activity, including segment efforts
#'
#' @param id numeric for id of the activity
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' 
#' @details Requires authentication stoken using the \code{\link{strava_oauth}} function and a user-created API on the strava website.
#' 
#' The id for each activity can be viewed using results from \code{\link{get_activity_list}}.
#' 
#' @return Data from an API request.
#' 
#' @export
#' 
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
#' get_activity(75861631, stoken)
#' }
get_activity <- function(id, stoken){

	req <- GET(url_activities(id), stoken, query = list(include_all_efforts=TRUE)) 
	stop_for_status(req)
	dataRaw <- content(req)
	return(dataRaw)

}