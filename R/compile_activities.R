#' converts a list of activities into a dataframe
#' 
#' converts a list of activities into a dataframe
#' 
#' @param actlist an \code{actlist} object returned by \code{\link{compile_activities}}
#' @param acts numeric indicating which activities to compile starting with most recent, defaults to all
#' @param ... arguments passed to or from other methods
#' 
#' @author Daniel Padfield
#' 
#' @return dataframe where each row is a different activity
#' 
#' @details each activity has a value for every column present across all activities, with NAs populating empty values
#'
#' @concept token
#' 
#' @export
#' 
#' @examples  
#' \dontrun{
#' stoken <- httr::config(ttoken = strava_oauth(app_name, app_client_id, app_secret, cache = TRUE))
#' 
#' acts <- get_activity_list(stoken)
#' 
#' acts_data <- compile_activities(acts)
#' }
compile_activities <- function(actlist, ...) UseMethod('compile_activities')

#' @rdname compile_activities
#'
#' @export
#'
#' @method compile_activities actlist
compile_activities.actlist <- function(actlist, acts = NULL, ...){
	if(is.null(acts)) acts <- 1:length(actlist)
	actlist <- actlist[acts]
	temp <- unlist(actlist)
	att <- unique(attributes(temp)$names)
	return(plyr::ldply(actlist, compile_activity, columns = att))
}
