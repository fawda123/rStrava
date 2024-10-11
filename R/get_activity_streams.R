#' Retrieve streams for activities, and convert to a dataframe
#' 
#' Retrieve streams for activities, and convert to a dataframe.
#' 
#' @param act_data an \code{list} object returned by \code{\link{get_activity_list}} or a \code{data.frame} returned by \code{\link{compile_activities}}
#' @param acts numeric indicating which activities to compile starting with most recent, defaults to all
#' @param id optional character vector to specify the id(s) of the activity/activities to plot, \code{acts} is ignored if provided
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function 
#' @param types list indicating which streams to get for each activity, defaults to all available, see details.
#' @param resolution chr string for the data resolution to retrieve, can be "low", "medium", "high", defaults to all
#' @param series_type	chr string for merging the data if \code{resolution} is not equal to "all". Accepted values are "distance" (default) or "time".
#' @param ... arguments passed to or from other methods
#' 
#' @author Lorenzo Gaborini
#' 
#' @return A stream frame object (\code{strframe} that includes a data frame for the stream data along with the units
#' 
#' @details 
#' 
#' Each activity has a value for every column present across all activities, with NAs populating missing values.
#' 
#' For the \code{types} argument, the default is \code{type = NULL} which will retrieve all available stream types.  The available stream types can be any of \code{time}, \code{latlng}, \code{distance}, \code{altitude}, \code{velocity_smooth}, \code{heartrate}, \code{cadence}, \code{watts}, \code{temp}, \code{moving}, or \code{grade_smooth}.  To retrieve only a subset of the types, pass a list argument with the appropriate character strings to \code{type}, e.g., \code{type = list("time", "latlng", "distance")}.
#' 
#' Invalid HTTP requests (404 or 400 code) may sometimes occur for activities with incomplete data, e.g., stationary activities with no distance information.  In such cases, changing the `series_type` and `resolution` arguments may be needed, e.g., `series_type = "time"` and `resolution = "medium"`. 
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
#' strms_data <- get_activity_streams(my_acts, stoken, acts = 1:2)
#' 
#' }
get_activity_streams <- function(act_data, ...) UseMethod('get_activity_streams')

#' @rdname get_activity_streams
#'
#' @export
#'
#' @method get_activity_streams list
get_activity_streams.list <- function(act_data, stoken, acts = NULL, id = NULL, types = NULL, resolution = 'high', series_type = 'distance', ...){
	
	act_data <- compile_activities(act_data, acts = acts, id = id)
	
	get_activity_streams.actframe(act_data, stoken, types = types, resolution = resolution, series_type = series_type)
	
}

#' @rdname get_activity_streams
#'
#' @export
#'
#' @method get_activity_streams actframe
get_activity_streams.actframe <- function(act_data, stoken, types = NULL, resolution = 'high', series_type = 'distance', ...){

	# Setup default streams
	types.all <- list("time", "latlng", "distance", "altitude", "velocity_smooth", "heartrate", "cadence", "watts", "temp", "moving", "grade_smooth")
	force(types)
	if (is.null(types)) {
		types <- unlist(types.all)
	} else {
		if (!all(types %in% types.all)) {
			types.all %>% paste(collapse = ' ') %>% paste('types must be in:', .) %>% stop()
		}
	}
	
	# stop if manual activity
	chk <- act_data$manual
	chk <- act_data[as.logical(chk), 'id']
	if(length(chk) > 0)
		stop("Cannot get streams for manual activities: ", paste(chk, collapse = ', '))

	# Get unit types and values attributes
	unit_type <- attr(act_data, 'unit_type')
	unit_vals <- attr(act_data, 'unit_vals')
	
	# Setup requested ids
	list.ids <- as.list(act_data$id)
	
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
	   
	   unit_vals <- c(distance = 'km', speed = 'km/hr', elevation = 'm', temperature = '\u00B0C')
	   
	}
	
	if (unit_type == 'imperial') {
	   
	   # distance from m to mi
	   # velocity_smooth from m/s to mi/hr
	   # altitude in m to ft
	   # temp from C to F
	   out <- dplyr::mutate(out, 
	                        distance = distance * 0.000621371,
	                        velocity_smooth = velocity_smooth * 2.23694,
	                        altitude = altitude * 3.28084,
	                        temp = temp * 9/5 + 32
	   )
	   
	   unit_vals <- c(distance = 'mi', speed = 'mi/hr', elevation = 'ft', temperature = '\u00B0F')
	   
	}
	
	# Drop added columns
	out <- dplyr::select(out, dplyr::one_of(cols.out))
	
	
	# create strframe object
	out <- structure(
      .Data = out, 
      class = c('strframe', 'data.frame'),
      unit_type = unit_type, 
      unit_vals = unit_vals
	)
	
	return(out)
	
}

