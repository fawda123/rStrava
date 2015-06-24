#' Get basic data for an athlete
#' 
#' Get basic athlete data for an athlete using an API request
#' 
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' @param id string or integer of athlete
#' 
#' @details Requires authentication stoken using the \code{\link{strava_oauth}} function and a user-created API on the strava website.
#' 
#' @return Data from an API request to \url{https://strava.com/api/v3/athlete}.  Specifically, a list of athlete information including athlete name, location, followers, etc. as described here: \url{https://strava.github.io/api/v3/athlete/}.
#' 
#' @concept token
#' 
#' @import httr
#' 
#' @examples
#' \dontrun{
#' get_athlete(stoken, id = '2527465')
#' }
get_athlete <-function(stoken, id = NULL){

	dataRaw <- get_basic(url_athlete(id), stoken)
	return(dataRaw)
	
}
