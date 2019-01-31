#' Get an activities list
#'
#' Get an activities list of the desired type (club, user)
#'
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' @param id string for id of the activity or club if \code{club = TRUE}
#' @param club logical if you want the activities of a club
#' 
#' @details Requires authentication stoken using the \code{\link{strava_oauth}} function and a user-created API on the strava website.  If retrieving activities using individual \code{id} values, the output list returned contains additional information from the API and the results have not been tested with the functions in this package.  It is better practice to retrieve all activities (as in the example below), use \code{\link{compile_activities}}, and then filter by individual activities.
#' 
#' @return A list of activities for further processing or plotting.
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
#' get_activity_list(stoken)
#' }
get_activity_list <- function(stoken, id = NULL, club = FALSE){
	#stoken:  Configured token (output from config(token = strava_oauth(...)))
	#id:      ID of the activity or club if club=TRUE (string)
	#club:    TRUE if you want the activities of a club (logic)
	
	# get individual id activities for user
	if(!is.null(id) & !club){
		dataRaw <- list()
		
		for(i in id){
			
			tmp <- get_pages(url_activities(id = i), stoken, All=TRUE)
			dataRaw <- c(dataRaw, list(tmp))
			
		}
		
	# otherwise get all
	} else {
		
		if (club){
			dataRaw <- get_pages(url_activities(id = id, club = club), stoken, per_page = 200, page_id = 1, page_max = 1)
		} else {
			dataRaw <- get_pages(url_activities(id = id), stoken, All=TRUE)
		}
	
	}
		
	return(dataRaw)
	
}