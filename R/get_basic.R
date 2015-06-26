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
#' @concept token
#' 
#' @import httr
get_basic <- function(url_, stoken, queries = NULL){
	
	req <- GET(url_, stoken, query = queries)
	ratelimit(req)
	stop_for_status(req)
	dataRaw <- content(req)
	return (dataRaw)
	
}
