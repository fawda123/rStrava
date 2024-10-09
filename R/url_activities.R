#' Set the url of activities for different activity lists
#' 
#' Set the url of activities for different activity lists
#' 
#' @param id string for id of the activity or club if \code{club = TRUE}
#' @param club logical if you want the activities of a club
#'
#' @details This function concatenates appropriate strings so no authentication token is required.  This is used internally by other functions.
#' 
#' @return The set url.
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
#' url_activities('2837007')
#' }
url_activities <- function(id = NULL, club = FALSE){
	
	url_ <- "https://www.strava.com/api/v3/activities/"
	if(!is.null(id)){
		
		if(any(!is.character(id)))
			stop('id must be a character vector')
		
		if(club){#Url for the activities of the club with ID = id
			url_ <- paste("https://www.strava.com/api/v3/clubs/", id,"/activities", sep="")
		}
		else{#Url for an specific activity
			url_ <- paste(url_, id, sep = "")
		}
	}
	else{#Url for the list of activities of the authenticated user
		url_ <- paste(url_athlete(),"/activities", sep = "")
	}
	
	return(url_)      
}
