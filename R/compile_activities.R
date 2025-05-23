#' converts a list of activities into a dataframe
#' 
#' converts a list of activities into a dataframe
#' 
#' @param actlist an activities list returned by \code{\link{get_activity_list}}
#' @param acts numeric indicating which activities to compile starting with most recent, defaults to all
#' @param id optional character vector to specify the id(s) of the activity/activities to plot, \code{acts} is ignored if provided
#' @param units chr string indicating metric or imperial
#' 
#' @author Daniel Padfield
#' 
#' @return An activities frame object (\code{actframe} that includes a data frame for the data and attributes for the distance, speed, and elevation units
#' 
#' @details each activity has a value for every column present across all activities, with NAs populating empty values
#'
#' @concept token
#' 
#' @seealso \code{\link{compile_club_activities}} for compiling an activities list for club activities
#' 
#' @export
#' 
#' @examples  
#' \dontrun{
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, app_secret, cache = TRUE))
#' 
#' my_acts <- get_activity_list(stoken)
#' 
#' acts_data <- compile_activities(my_acts)
#' 
#' # show attributes
#' attr(acts_data, 'unit_type')
#' attr(acts_data, 'unit_vals')
#' }
compile_activities <- function(actlist, acts = NULL, id = NULL, units = 'metric'){
	
	# check id is character
	if(!is.null(id) & any(!is.character(id))) 
		stop('id must be a character vector')
	
	# check units
	if(!units %in% c('metric', 'imperial')) 
		stop('units must be metric or imperial')
	
	if(identical(names(actlist[[1]]), c("resource_state", "athlete", "name", "distance", "moving_time", "elapsed_time", "total_elevation_gain", "type", "workout_type")))
		stop('use "compile_club_activities" for club activities')
	
	# get all if acts and id empty
	if(is.null(acts) & is.null(id)) 
		acts <- 1:length(actlist)
	
	# get index of id if provided
	if(!is.null(id)){
		ids <- unlist(lapply(actlist, function(x) x$id))
		acts <- which(ids %in% id)
		
		if(length(acts) != length(id)){
			mis <- id[!id %in% ids]
			mis <- paste(mis, collapse = ', ')
			stop(paste('activity id', mis, 'not found'))
		}
		
	}
	
	actlist <- actlist[acts]
	temp <- unlist(actlist)
	att <- unique(attributes(temp)$names)
	out <- purrr::map_dfr(actlist, compile_activity, columns = att)
	
	# convert relevant columns to numeric
	cols <- c('achievement_count', 'athlete.resource_state', 'athlete_count', 'average_speed', 'average_watts', 'comment_count', 'distance', 'elapsed_time', 'elev_high', 'elev_low', 'end_latlng1', 'end_latlng2', 'kilojoules', 'kudos_count', 'map.resource_state', 'max_speed', 'moving_time', 'photo_count', 'resource_state', 'start_latitude', 'start_latlng1', 'start_latlng2', 'start_longitude', 'total_elevation_gain', 'total_photo_count')
	cols <- names(out)[names(out) %in% cols]
	out <- dplyr::mutate_at(out, cols, as.numeric)

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
			max_speed = max_speed * 2.23694,
			total_elevation_gain = total_elevation_gain * 3.28084
		)
		
		# these will be missing if trainer == T
		if(sum(names(out) %in% c('elev_high', 'elev_low')) == 2)
			out <- dplyr::mutate(out, 
				elev_high = elev_high * 3.28084, 
				elev_low = elev_low * 3.28084
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
