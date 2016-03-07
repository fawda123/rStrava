#' Set the url for stream requests
#' 
#' Set the url for stream requests
#'
#' @param id numeric for id of the request
#' @param request chr string defining the stream type, must be "activities", "segment_efforts", "segments"
#' @param types list of chr strings with any combination of "time", "latlng", "distance", "altitude", "velocity_smooth", "heartrate", "cadence", "watts", "temp", "moving", or "grade_smooth"
#' 
#' @details Function is used internally within \code{\link{get_streams}}. From the API documentation, 'streams' is the Strava term for the raw data associated with an activity.
#' 
#' @export
#' 
#' @return A url string.
#' 
#' @concept token
#' 
#' @examples
#' url_streams(123)
url_streams  <- function(id, request = "activities", types = list("latlng")){
	
	#Converting the list of types into the proper string
	strtypes <- types[[1]]
	if(length(types)>1){
		for(i in 2:length(types)){
			strtypes <- paste(strtypes,",", types[[i]], sep="")
		}
	}
	
	# Creating the url string
	url_ <- paste("https://www.strava.com/api/v3/", request, "/", id, "/streams/", strtypes, sep="")
	
	return(url_)
	
}
