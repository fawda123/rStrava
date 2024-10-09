#' Get club data
#' 
#' Get club data for a given request
#'
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' @param id character vector for id of the club, defaults to authenticated club of the athlete
#' @param request chr string, must be "members", "activities" or \code{NULL} for club details
#'
#' @details Requires authentication stoken using the \code{\link{strava_oauth}} function and a user-created API on the strava website.
#' 
#' @return Data from an API request.
#' 
#' @export
#' 
#' @concept token
#' 
#' @examples
#' \dontrun{
#' # create authentication token
#' # requires user created app name, id, and secret from Strava website
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, 
#' 	app_secret, cache = TRUE))
#' 
#' get_club(stoken)
#' }
get_club <- function(stoken, id=NULL, request=NULL){
	
	if(is.null(id)){
		dataRaw <- get_basic(url_clubs(), stoken)
	}
	else{ 
		switch(request,
					 NULL = dataRaw <- get_basic(url_clubs(id), stoken),
					 
					 activities = dataRaw <- get_activity_list(stoken, id, club = TRUE),
					 
					 members = dataRaw <- get_pages(url_clubs(id = id, request = request), stoken,
					 															 per_page = 200, page_id = 1, page_max = 1)
		)
	}
	return(dataRaw)
}