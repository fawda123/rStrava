#' converts a list of activities into a dataframe
#' 
#' converts a list of activities into a dataframe
#' 
#' @param actlist an activities list returned by \code{\link{get_activity_list}}
#' @param acts numeric indicating which activities to compile starting with most recent, defaults to all
#' @param units chr string indicating metric or imperial
#' @param ... arguments passed to or from other methods
#' 
#' @author Daniel Padfield
#' 
#' @return An actitities frame object (\code{actframe} that includes a data frame for the data and attributes for the distance, speed, and elevation units
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
#' 
#' }
compile_activities <- function(actlist, acts = NULL, units = 'metric'){
	
	# check units
	if(!units %in% c('metric', 'imperial')) 
		stop('units must be metric or imperial')
	
	if(is.null(acts)) acts <- 1:length(actlist)
	actlist <- actlist[acts]
	temp <- unlist(actlist)
	att <- unique(attributes(temp)$names)
	out <- plyr::ldply(actlist, compile_activity, columns = att)
	
	# convert relevant columns to numeric
	out <- dplyr::mutate_at(out, c('achievement_count', 'athlete.resource_state', 'athlete_count', 'average_speed', 'average_watts', 'comment_count', 'distance', 'elapsed_time', 'elev_high', 'elev_low', 'end_latlng1', 'end_latlng2', 'kilojoules', 'kudos_count', 'map.resource_state', 'max_speed', 'moving_time', 'photo_count', 'resource_state', 'start_latitude', 'start_latlng1', 'start_latlng2', 'start_longitude', 'total_elevation_gain', 'total_photo_count'), as.numeric)
	
	if(units == 'metric'){
		
		# distance from m to km
		# average_speed from m/s to km/hr
		# elev_high in m to m
		# elev_low in m to m
		# max_speed from m/s to km/hr
		# total_elevation_gain from m to m
		out <- dplyr::mutate(out, 
			distance = distance / 1000,
			average_speed = average_speed * 3.6, 
			max_speed = max_speed * 3.6
		)
		
		unit_type <- units
		unit_vals <- c(distance = 'km', speed = 'km/hr', elevation = 'm')
	
	}
	
	if(units == 'imperial'){
		
		# distance from m to mi
		# average_speed from m/s to mi/hr
		# elev_high in m to ft
		# elev_low in m to ft
		# max_speed from m/s to mi/hr
		# total_elevation_gain from m to ft
		out <- dplyr::mutate(out, 
			distance = distance * 0.000621371,
			average_speed = average_speed * 2.23694, 
			elev_high = elev_high * 3.28084, 
			elev_low = elev_low * 3.28084,
			max_speed = max_speed * 2.23694,
			total_elevation_gain = total_elevation_gain * 3.28084
		)
		
		unit_type <- units
		unit_vals <- c(distance = 'mi', speed = 'mi/hr', elevation = 'ft')
	
	}
	
	# create actframe object
	out <- structure(
    .Data = out, 
    class = c('actframe', 'data.frame'),
		unit_type = units, 
		unit_vals = unit_vals
	)
	
	return(out)
}
