#' Retrieve a summary of the segments starred by an athlete
#'
#' Retrieve a summary of the segments starred by an athlete
#'
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' @param id numeric for id of the athlete, defaults to authenticated athlete

#' @details Requires authentication stoken using the \code{\link{strava_oauth}} function and a user-created API on the strava website.
#' 
#' @return Data from an API request.
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
#' get_starred(stoken)
#' }
get_starred <- function(stoken, id = NULL){     

	dataRaw <- get_basic(url_segment(id=id, request="starred"), stoken)
	return(dataRaw)

	}