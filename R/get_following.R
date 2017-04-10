#' Get followers, friends, or both-following
#' 
#' Get followers or friends of the athlete or both-following relative to another user
#' 
#' @param following string equal to `friends', `followers', or `both-following'
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' @param id string or integer of athlete, taken from \code{stoken} if \code{NULL}
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
#' get_following('friends', stoken)
#' }
get_following <- function(following, stoken, id = NULL){
	
	url_ <- paste(url_athlete(id),"/", following, sep = "")
	dataRaw <- get_basic(url_, stoken)
	return(dataRaw)
	
}