#' Retrieve streams for activities, and convert to a dataframe
#' 
#' Retrieve streams for activities, and convert to a dataframe.
#' 
#' @param actframe an activity frame returned by \code{\link{compile_activities}}
#' @param acts numeric indicating which activities to compile starting with most recent, defaults to all
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function 
#' @param types list indicating which streams (lat/lng/time/...) to get for each activity, defaults to all available
#' @inheritParams get_streams
#' 
#' @author Lorenzo Gaborini
#' 
#' @return A stream frame object (\code{str_act_frame} that includes a data frame for the stream data along with the units
#' 
#' @details Each activity has a value for every column present across all activities, with NAs populating missing values.
#'
#' @concept token
#' 
#' @export
#' 
#' @examples  
#' \dontrun{
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, app_secret, cache = TRUE))
#' 
#' my_acts <- get_activity_list(stoken)
#' 
#' acts_data <- get_activity_streams(my_acts, stoken, acts = 1:2)
#' 
#' }
get_activity_streams <- function(actframe, stoken, acts = NULL, types = NULL, resolution = 'high', series_type = 'distance'){
	
	# Setup default streams
	types.all <- list("time", "latlng", "distance", "altitude", "velocity_smooth", "heartrate", "cadence", "watts", "temp", "moving", "grade_smooth")
	force(types)
	if (is.null(types)) {
		types <- types.all
	} else {
		if (!all(types %in% types.all)) {
			types.all %>% paste(collapse = ' ') %>% paste('types must be in:', .) %>% stop()
		}
	}

	# Get unit types and values attributes
	unit_type <- attr(actframe, 'unit_type')
	unit_vals <- attr(actframe, 'unit_vals')
	
	# Setup requested ids
	if (is.null(acts)) acts <- 1:nrow(actframe)
	list.ids <- as.list(actframe[acts,]$id)
	
	# Get all activity streams
	streams <- purrr::map(list.ids, ~ get_streams(stoken, id = ., request = 'activities', types = types, resolution = resolution, series_type = series_type))
	
	# Compile all streams and row-bind
	# NA columns are added if one activity is missing a requested stream
	out <- purrr::map2_dfr(streams, list.ids, compile_activity_streams)
	
	# Prepare dataframe for unit transformation
	# Avoid representing unrequested streams with NA columns
	# (Relevant if requesting a subset of stream types)
	#
	# Hackish:
	# pad non-retrieved fields with NAs, fix the units, then remove the added columns
	cols.out <- colnames(out)
	
	add_columns_if_not_exist <- function(x, cols_to_add) {
		new_cols <- setdiff(cols_to_add, colnames(x))
		if (length(new_cols) != 0) {
			x[, unlist(new_cols)] <- NA
		}
		x
	}
	out <- add_columns_if_not_exist(out, types.all)
	
	# Convert units
	# add NA for non-existing fields	
	if (unit_type == 'metric') {
	   
	   # distance from m to km
	   # velocity_smooth from m/s to km/hr
	   out <- dplyr::mutate(out, 
	                        distance = distance / 1000,
	                        velocity_smooth = velocity_smooth * 3.6
	   )
	   
	   unit_vals <- c(distance = 'km', speed = 'km/hr', elevation = 'm', temperature = '°C')
	   
	}
	
	if (unit_type == 'imperial') {
	   
	   # distance from m to mi
	   # velocity_smooth from m/s to mi/hr
	   # altitude in m to ft
	   # temp from °C to °F
	   out <- dplyr::mutate(out, 
	                        distance = distance * 0.000621371,
	                        velocity_smooth = velocity_smooth * 2.23694,
	                        altitude = altitude * 3.28084,
	                        temp = temp * 9/5 + 32
	   )
	   
	   unit_vals <- c(distance = 'mi', speed = 'mi/hr', elevation = 'ft', temperature = '°F')
	   
	}
	
	# Drop added columns
	out <- dplyr::select(out, one_of(cols.out))
	
	
	# create str_act_frame object
	out <- structure(
      .Data = out, 
      class = c('str_act_frame', 'data.frame'),
      unit_type = unit_type, 
      unit_vals = unit_vals
	)
	
	return(out)
	
}

