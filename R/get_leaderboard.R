#' Retrieve the leaderboard of a segment
#' 
#' Retrieve the leaderboard of a segment
#'
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' @param id numeric for id of the segment
#' @param nleaders numeric for number of leaders to retrieve
#' @param All logical to retrieve all of the list
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
#' get_leaderboard(stoken, id = 229781)
#' }
get_leaderboard <- function(stoken, id, nleaders = 10, All = FALSE){

	dataRaw <- get_pages(url_segment(id, request="leaderboard"), stoken, 
											 per_page = nleaders, All = All)
	return(dataRaw)
	
}