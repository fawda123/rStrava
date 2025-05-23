#' Set the url of the athlete to get data
#' 
#' Set the url of the athlete to get data using an ID
#' 
#' @param id character of athlete id assigned by Strava, NULL will set the authenticated user URL
#' 
#' @export
#' 
#' @details used by other functions
#' 
#' @return A character string of the athlete URL used for API requests
url_athlete <- function(id = NULL){

	url_ <- "https://www.strava.com/api/v3/athlete"
	if(!is.null(id)){
		
		if(any(!is.character(id)))
			stop('id must be a character vector')
		
		url_ <- paste(url_,"s/",id, sep = "")
		
	}
	return(url_)
	
}