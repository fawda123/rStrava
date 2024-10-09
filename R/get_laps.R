#' Retrieve the laps of an activity
#' 
#' Retrieve the laps of an activity
#' 
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' @param id character for id of the activity with the laps to request
#'
#' @details Requires authentication stoken using the \code{\link{strava_oauth}} function and a user-created API on the strava website.
#' 
#' @return Data from an API request.
#' 
#' @export
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
#' get_laps(stoken, id = '351217692')
#' }
get_laps <- function(stoken, id){
	
	if(any(!is.character(id)))
		stop('id must be a character vector')
	
	if (length(id) != 1){
		stop('only one activity id can be requested')
	}
	
	url_ <- paste("https://www.strava.com/api/v3/activities/", id, "/laps", sep="")
	dataRaw <- get_basic(url_, stoken)
	
	# categories to get from each lap
	desired_cols <- c("activity.id", "activity.resource_state", "athlete.id", "athlete.resource_state", 
										"average_heartrate", "average_speed", "distance", "elapsed_time", 
										"end_index", "id", "lap_index", "max_heartrate", "max_speed", 
										"moving_time", "name", "pace_zone", "resource_state", "split", 
										"start_date", "start_date_local", "start_index", "total_elevation_gain"
		) %>% 
		data.frame(ColNames = ., stringsAsFactors = F)	
	
	# format output
	out <- dataRaw %>% 
		purrr::map(function(x){
			
			out <- data.frame(unlist(x)) %>%
				dplyr::mutate(ColNames = rownames(.)) %>% 
				dplyr::left_join(desired_cols, ., by = 'ColNames') %>% 
				tidyr::spread(ColNames, unlist.x.)
			
		}) %>% 
		do.call('rbind', .)
	
	return(out)
	
}

