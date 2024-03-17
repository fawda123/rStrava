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
	
	# these are the names if querying api with date ranges
	# need to subset if querying by id
	tosel <- c("resource_state", "athlete", "name", "distance", "moving_time", 
		"elapsed_time", "total_elevation_gain", "type", "sport_type", 
		"workout_type", "id", "start_date", "start_date_local", "timezone", 
		"utc_offset", "location_city", "location_state", "location_country", 
		"achievement_count", "kudos_count", "comment_count", "athlete_count", 
		"photo_count", "map", "trainer", "commute", "manual", "private", 
		"visibility", "flagged", "gear_id", "start_latlng", "end_latlng", 
		"average_speed", "max_speed", "has_heartrate", "average_heartrate", 
		"max_heartrate", "heartrate_opt_out", "display_hide_heartrate_option", 
		"elev_high", "elev_low", "upload_id", "upload_id_str", "external_id", 
		"from_accepted_tag", "pr_count", "total_photo_count", "has_kudoed"
		)
	
	temp <- data.frame(unlist(x[tosel]), stringsAsFactors = F)
	temp$ColNames <- rownames(temp)
	temp <- tidyr::spread(temp, ColNames, unlist.x.tosel..)
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

