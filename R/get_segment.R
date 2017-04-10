#' Retrieve details about a specific segment
#' 
#' Retreive details about a specific segment
#'
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' @param id numeric for id of the segment
#' @param request chr string, must be "starred", "all_efforts", "leaderboard", "explore" or NULL for segment details
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
#' get_segment(stoken, id = 229781)
#' get_segment(stoken, id = 229781, request = 'leaderboard')
#' }
get_segment <- function(stoken, id = NULL, request = NULL){
	
	dataRaw <- get_basic(url_segment(id, request = request), stoken)
	return(dataRaw)
	
}
