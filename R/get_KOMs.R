#' Get KOMs/QOMs/CRs of an athlete
#' 
#' Get KOMs/QOMs/CRs of an athlete
#' 
#' @param id string or integer of athlete
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
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
#' get_KOMs(2837007, stoken)
#' }
get_KOMs <- function(id, stoken){

	url_ <- paste(url_athlete(id),"/koms", sep = "")
	dataRaw <- get_basic(url_, stoken)
	return(dataRaw)
	
}