#' Get an activities list
#'
#' Get an activities list of the desired type (club, friends, user)
#'
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' @param id string for id of the activity or club if \code{club = TRUE}
#' @param club logical if you want the activities of a club
#' @param friends logical if you want friends' activities of the authenticated user
#' 
#' @details Requires authentication stoken using the \code{\link{strava_oauth}} function and a user-created API on the strava website.
#' 
#' @return The set url.
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
#' get_activity_list(stoken, 2837007)
#' }
get_activity_list <- function(stoken, id = NULL, club = FALSE, friends = FALSE){
	#stoken:  Configured token (output from config(token = strava_oauth(...)))
	#id:      ID of the activity or club if club=TRUE (string)
	#friends: TRUE if you want the friends activities of the authenticated user (logic)
	#club:    TRUE if you want the activities of a club (logic)
	
	#This codes assumes requesting all the pages of activities. In other circunstances change the parameters of 'get_pages'
	
	if (friends | club){
		dataRaw <- get_pages(url_activities(id = id, club = club, friends=friends), stoken, per_page = 200, page_id = 1, page_max = 1)
	}
	else{
		dataRaw <- get_pages(url_activities(), stoken, All=TRUE)
	}
	
	return(dataRaw)
}