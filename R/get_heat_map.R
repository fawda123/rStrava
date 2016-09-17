#' Makes a heat map from your activity data
#' 
#' Makes a heat map from your activity data
#' 
#' @author Daniel Padfield, Marcus Beck
#' 
#' @concept token
#' 
#' @param act_data an \code{actlist} object returned by \code{\link{get_activity_list}} or a \code{data.frame} returned by \code{\link{compile_activities}}
#' @param acts numeric indicating which activities to plot based on index in \code{actlist}, defaults to most recent
#' @param alpha the opacity of the line desired. A single activity should be 1. Defaults to 0.5
#' @param f number specifying the fraction by which the range should be extended for the bounding box of the activities, passed to \code{\link[ggmap]{make_bbox}}
#' @param add_elev logical indicating if elevation is overlayed by color shading on the activity lines
#' @param as_grad logical indicating if elevation is plotted as percent gradient, applies only if \code{add_elev = TRUE}
#' @param key chr string of Google API key for elevation data, passed to \code{\link[rgbif]{elevation}}, see details
#' @param size numeric indicating width of activity lines
#' @param col chr string indicating either a single color of the activity lines if \code{add_grad = FALSE} or a color palette passed to \code{\link[ggplot2]{scale_fill_distiller}} if \code{add_grad = TRUE}
#' @param expand a numeric multiplier for expanding the number of lat/lon points on straight lines.  This can create a smoother elevation gradient if \code{add_grad = TRUE}.  Set \code{expand = 1} to suppress this behavior.  
#' @param maptype chr string indicating the type of base map obtained from Google maps, values are \code{terrain} (default), \code{satellite}, \code{roadmap}, or \code{hybrid} 
#' @param units chr string indicating plot units as either metric or imperial
#' @param ... arguments passed to or from other methods
#' 
#' @details uses \code{\link{get_all_LatLon}} to produce a dataframe of latitudes and longitudes to use in the map. Uses {ggmap} to produce map and ggplot2 it
#' 
#' @return plot of activity on a Google map
#' 
#' @export
#' 
#' @examples 
#' \dontrun{
#' # get my activities
#' stoken <- httr::config(ttoken = strava_oauth(app_name, app_client_id, app_secret, cache = TRUE))
#' my_acts <- get_activity_list(stoken)
#' 
#' # default
#' get_heat_map(my_acts, acts = 1, alpha = 1)
#' 
#' # plot elevation on locations, requires key
#' mykey <- 'Get Google API key'
#' get_heat_map(my_acts, acts = 1, alpha = 1, key = mykey, add_elev = TRUE, col = 'Spectral', size = 2)
#' 
#' # compile first, change units
#' my_acts <- compile_activities(my_acts, acts = 1, units = 'imperial')
#' get_heat_map(my_acts, key = mykey, alpha = 1, add_elev = T, col = 'Spectral', size = 2)
#' }
get_heat_map <- function(act_data, ...) UseMethod('get_heat_map')

#' @rdname get_heat_map
#'
#' @export
#'
#' @method get_heat_map list
get_heat_map.list <- function(act_data, acts = 1, alpha = NULL, f = 1, key = NULL, add_elev = FALSE, as_grad = FALSE, size = 0.5, col = 'red', expand = 10, maptype = 'terrain', units = 'metric', ...){
	
	# compile
	act_data <- compile_activities(act_data, acts = acts, units = units)
	 
	get_heat_map.actframe(act_data, alpha = alpha, f = f, key = key, add_elev = add_elev, as_grad = as_grad, size = size, col = col, expand = expand, maptype = maptype, ...)	
	
}
	
#' @rdname get_heat_map
#'
#' @export
#'
#' @method get_heat_map actframe
get_heat_map.actframe <- function(act_data, alpha = NULL, f = 1, key = NULL, add_elev = FALSE, as_grad = FALSE, size = 0.5, col = 'red', expand = 10, maptype = 'terrain', ...){

	# get unit types and values attributes
	unit_type <- attr(act_data, 'unit_type')
	unit_vals <- attr(act_data, 'unit_vals')
	
	if(is.null(alpha)) alpha <- 0.5
	
	# data to plot
	temp <- get_all_LatLon('map.summary_polyline', act_data)
	temp$activity <- as.numeric(factor(temp$map.summary_polyline))
	temp$map.summary_polyline <- NULL
		
	# xy lims
	xlim <- c(min(temp$lon), max(temp$lon))
	ylim <- c(min(temp$lat), max(temp$lat))
	bbox <- ggmap::make_bbox(temp$lon, temp$lat, f = f)
	
	# map and base plot
	map <- suppressWarnings(suppressMessages(ggmap::get_map(bbox, maptype = maptype)))
	pbase <- ggmap::ggmap(map) +
		ggplot2::coord_equal() +
		ggplot2::theme(axis.title = ggplot2::element_blank())
	
	# add elevation to plot
	if(add_elev){
		
		# check if key provided
		if(is.null(key))
			stop('Google API key is required if plotting elevation')

		# expand lat/lon for each activity
		temp <- split(temp, temp$activity)
		temp <- lapply(temp, function(x) {
		
			xint <- stats::approx(x = x$lon, n = expand * nrow(x))$y
			yint <- stats::approx(x = x$lat, n = expand * nrow(x))$y
			data.frame(activity = unique(x$activity), lat = yint, lon = xint)
			
		})
		temp <- do.call('rbind', temp)
		
		# get elevation
		temp$ele <- rgbif::elevation(latitude = temp$lat, longitude = temp$lon, key = key)$elevation
		temp$ele <- pmax(0, temp$ele)
		temp <- dplyr::mutate(temp, EleDiff = c(0, diff(ele)),
									 distdiff = c(0, diff(rStrava::get_dists(temp))),
									 grad = c(0, (EleDiff[2:nrow(temp)]/10)/distdiff[2:nrow(temp)]))
		
		# plot gradient 
		if(as_grad){
			
			p <- pbase +
				ggplot2::geom_path(ggplot2::aes(x = lon, y = lat, group = activity, colour = grad), 
													 alpha = alpha, data = temp, size = size) +
				ggplot2::scale_colour_distiller('Gradient (%)', palette = col)
		
		# plot elevation			
		} else {
			
			# legend label for elevation
			leglab <- paste0('Elevation (', unit_vals['elevation'], ')')
		
			# change units if imperial
			if(unit_type %in% 'imperial'){
			
				temp$ele <- temp$ele *  3.28084
			
			}
			
			p <- pbase +
				ggplot2::geom_path(ggplot2::aes(x = lon, y = lat, group = activity, colour = ele), 
													 alpha = alpha, data = temp, size = size) +
				ggplot2::scale_colour_distiller(leglab, palette = col)
			
		}
			
	# otherwise dont		
	} else {
		
		p <- pbase +
			ggplot2::geom_path(ggplot2::aes(x = lon, y = lat, group = activity), 
												 alpha = alpha, data = temp, size = size, colour = col)
		
	}
	
	return(p)
	
}
