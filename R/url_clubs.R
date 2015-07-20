#' Set the url of the clubs for the different requests
#' 
#' Set the url of the clubs for the different requests
#'
#' @param id numeric for id of the club, defaults to authenticated club of the athlete
#' @param request chr string, must be "members", "activities" or \code{NULL} for club details
#' 
#' @details Function is used internally within \code{\link{get_club}}
#' 
#' @export
#' 
#' @return A url string.
#' 
#' @concept token
#' 
#' @examples
#' url_clubs()
#' 
#' url_clubs(123, request = 'members')
url_clubs <- function(id = NULL, request = NULL){
	
	if(is.null(id)){#Clubs of the authenticated athlete
		url_ <- paste(url_athlete(), "/clubs", sep = "")
	}
	else{ #request must be "members", "activities" or NULL for club details
		url_ <- paste("https://www.strava.com/api/v3/clubs/", id,"/", request, sep = "")
	}
	
	return(url_)
	
}   