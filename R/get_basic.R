#' Get basic Strava data
#' 
#' Get basic Strava data with requests that don't require pagination
#' 
#' @param url_ string of url for the request to the API
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' @param queries list of additional queries or parameters 
#'
#' @details Requires authentication stoken using the \code{\link{strava_oauth}} function and a user-created API on the strava website.   
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
#' # get basic user info
#' get_basic('https://strava.com/api/v3/athlete', stoken)
#' }
get_basic <- function(url_, stoken, queries = NULL){
	
	req <- GET(url_, stoken, query = queries)
	ratelimit(req)
	stop_for_status(req)
	dataRaw <- content(req)
	return (dataRaw)
	
}
