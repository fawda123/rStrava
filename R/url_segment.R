#' Set the url for the different segment requests
#' 
#' Set the url for the different segment requests
#'
#' @param id numeric for id of the segment if \code{request = "all_efforts"} or \code{"leaderboard"}, or id of the athlete if \code{request = "starred"}, or NULL if using \code{request = "explore"} or \code{"starred"} of the athenticated user
#' @param request chr string, must be "starred", "all_efforts", "leaderboard", "explore" or NULL for segment details
#' 
#' @details Function is used internally within \code{\link{get_segment}}, \code{\link{get_starred}}, \code{\link{get_leaderboard}}, \code{\link{get_efforts_list}}, and \code{\link{get_explore}}
#' 
#' @return A url string.
#' 
#' @export
#' 
#' @concept token
#' 
#' @examples
#' url_segment()
#' 
#' url_segment(id = 123, request = 'leaderboard')
url_segment <- function(id = NULL, request = NULL){
	
	if(!is.null(request)){
		if(!is.null(id) & request == "starred"){
			url_ <- paste("https://www.strava.com/api/v3/athlete/", id,"/segments/starred", sep="")
		}
		else{
			url_ <- "https://www.strava.com/api/v3/segments/"
			if(request == "starred" | request == "explore"){
				url_ <- paste(url_, request, sep="")
			}
			else{
				url_ <- paste(url_, id, "/", request, sep = "")
			}
		}
	}
	else{
		url_ <- paste("https://www.strava.com/api/v3/segments/", id, sep="")
	}
	return(url_)
	
}
