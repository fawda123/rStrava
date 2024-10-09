#' Set the url of the equipment item to get data
#' 
#' Set the url of the equipment item to get data using an ID
#' 
#' @param id string of gear id assigned by Strava
#' 
#' @export
#' 
#' @details used by other functions
#' 
#' @return A character string of the gear URL used for API requests
url_gear <- function(id){
	
	if(any(!is.character(id)))
		stop('id must be a character vector')
	
	url_ <- "https://www.strava.com/api/v3/gear/"
	url_ <- paste(url_, id, sep = "")
	return(url_)
	
}