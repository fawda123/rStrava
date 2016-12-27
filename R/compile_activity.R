#' convert a single activity list into a dataframe
#' 
#' convert a single activity list into a dataframe
#' @author Daniel Padfield
#' @details used internally in \code{\link{compile_activities}}
#' @param x a list containing details of a single Strava activity
#' @param columns a character vector of all the columns in the list of Strava activities. Produced automatically in \code{\link{compile_activities}}. Leave blank if running for a single activity list.
#' @return dataframe where every column is an item from a list. Any missing columns rom the total number of columns 
#' @concept token
#' @examples 
#' \dontrun{
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, app_secret, cache = TRUE))
#' 
#' acts <- get_activity_list(stoken)
#' 
#' compile_activity(acts[1])}
#' @export

compile_activity <- function(x, columns){
	
	temp <- data.frame(unlist(x), stringsAsFactors = F)
	temp$ColNames <- rownames(temp)
	temp <- tidyr::spread(temp, ColNames, unlist.x.)
	if(missing(columns)){return(temp)}
	else{
		cols_not_present <- columns[! columns %in% colnames(temp)]
		if(length(cols_not_present) == 0){return(temp)}
		else{
			cols_not_present <- data.frame(cols = cols_not_present)
			cols_not_present$value <- NA
			if(nrow(cols_not_present) >= 1){cols_not_present <- tidyr::spread(cols_not_present, cols, value)}
			if(nrow(cols_not_present) == 1){temp <- cbind(temp, cols_not_present)}
			return(temp)}
	}
}

