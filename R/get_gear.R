#' Get gear details from its identifier
#' 
#' Get gear details from its identifier
#' 
#' @param id string, identifier of the equipment item
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
#' get_gear("g2275365", stoken)
#' }
get_gear <- function(id, stoken){
	
	url_ <- url_gear(id)
	dataRaw <- get_basic(url_, stoken)
	return(dataRaw)
	
}