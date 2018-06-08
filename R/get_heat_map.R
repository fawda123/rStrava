#' Makes a heat map from your activity data
#' 
#' Makes a heat map from your activity data
#' 
#' @author Daniel Padfield, Marcus Beck
#' 
#' @concept token
#' 
#' @param act_data an activities list object returned by \code{\link{get_activity_list}} or a \code{data.frame} returned by \code{\link{compile_activities}}
#' @param acts numeric indicating which activities to plot based on index in the activities list, defaults to most recent
#' @param alpha the opacity of the line desired. A single activity should be 1. Defaults to 0.5
#' @param f number specifying the fraction by which the range should be extended for the bounding box of the activities, passed to \code{\link[ggmap]{make_bbox}}
#' @param add_elev logical indicating if elevation is overlayed by color shading on the activity lines
#' @param as_grad logical indicating if elevation is plotted as percent gradient, applies only if \code{add_elev = TRUE}
#' @param dist logical if distance is plotted along the route with \code{\link[ggrepel]{geom_label_repel}}
#' @param distval numeric indicating rounding factor for distance labels which has direct control on label density, see details 
#' @param key chr string of Google API key for elevation data, passed to \code{\link[rgbif]{elevation}}, see details
#' @param size numeric indicating width of activity lines
#' @param col chr string indicating either a single color of the activity lines if \code{add_grad = FALSE} or a color palette passed to \code{\link[ggplot2]{scale_fill_distiller}} if \code{add_grad = TRUE}
#' @param expand a numeric multiplier for expanding the number of lat/lon points on straight lines.  This can create a smoother elevation gradient if \code{add_grad = TRUE}.  Set \code{expand = 1} to suppress this behavior.  
#' @param maptype chr string indicating the base map type relevant for the \code{source}, passed to \code{\link[ggmap]{get_map}}
#' @param source chr string indicating map source, passed to \code{\link[ggmap]{get_map}}, currently only \code{"google"} and \code{"osm"} are supported
#' @param units chr string indicating plot units as either metric or imperial, this has no effect if input data are already compiled with \code{\link{compile_activities}}
#' @param ... arguments passed to or from other methods
#' 
#' @details uses \code{\link{get_latlon}} to produce a dataframe of latitudes and longitudes to use in the map. Uses ggmap to produce the map and ggplot2 to plot the route.
#' 
#' The Google API key for elevation is easy to obtain, follow instructions here: https://developers.google.com/maps/documentation/elevation/#api_key
#' 
#' The \code{distval} argument is passed to the \code{digits} argument of \code{round}. This controls the density of the distance labels, e.g., 1 will plot all distances in sequenc of 0.1, 0 will plot all distances in sequence of one, -1 will plot all distances in sequence of 10, etc. 
#' 
#' @return plot of activity on a Google map
#' 
#' @export
#' 
#' @import magrittr
#' 
#' @examples 
#' \dontrun{
#' # get my activities
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, app_secret, cache = TRUE))
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
#' my_acts <- compile_activities(my_acts, acts = 156, units = 'imperial')
#' get_heat_map(my_acts, key = mykey, alpha = 1, add_elev = T, col = 'Spectral', size = 2, 
#'   maptype = 'satellite')
#' }
get_heat_map <- function(act_data, ...) UseMethod('get_heat_map')

#' @rdname get_heat_map
#'
#' @export
#'
#' @method get_heat_map list
get_heat_map.list <- function(act_data, acts = 1, alpha = NULL, f = 0.1, key = NULL, add_elev = FALSE, as_grad = FALSE, dist = TRUE, distval = 0, size = 0.5, col = 'red', expand = 10, maptype = 'terrain', source = 'google', units = 'metric', ...){
	
	# compile
	act_data <- compile_activities(act_data, acts = acts, units = units)

	get_heat_map.actframe(act_data, alpha = alpha, f = f, key = key, add_elev = add_elev, as_grad = as_grad, dist = dist, distval = distval, size = size, col = col, expand = expand, maptype = maptype, source = source, ...)	
	
}
	
#' @rdname get_heat_map
#'
#' @export
#'
#' @method get_heat_map actframe
get_heat_map.actframe <- function(act_data, alpha = NULL, f = 1, key = NULL, add_elev = FALSE, as_grad = FALSE, dist = TRUE, distval = 0, size = 0.5, col = 'red', expand = 10, maptype = 'terrain', source = 'google', ...){

	# get unit types and values attributes
	unit_type <- attr(act_data, 'unit_type')
	unit_vals <- attr(act_data, 'unit_vals')

	# warning if units conflict
	args <- as.list(match.call())
	if('units' %in% names(args))
		if(args$units != unit_type)
			warning('units does not match unit type, use compile_activities with different units')
				
	if(is.null(alpha)) alpha <- 0.5
	
	# data to plot
	temp <- dplyr::group_by(act_data, map.summary_polyline) %>%
		dplyr::do(get_latlon(.)) %>%
		dplyr::ungroup()
	temp$activity <- as.numeric(factor(temp$map.summary_polyline))
	temp$map.summary_polyline <- NULL
	
	# expand lat/lon for each activity
	temp <- split(temp, temp$activity)
	temp <- lapply(temp, function(x) {
	
		xint <- stats::approx(x = x$lon, n = expand * nrow(x))$y
		yint <- stats::approx(x = x$lat, n = expand * nrow(x))$y
		data.frame(activity = unique(x$activity), lat = yint, lon = xint)
		
	})
	temp <- do.call('rbind', temp)
	
	# get distances, default is km
	temp <- dplyr::mutate(temp, distance = get_dists(lon, lat))
	if(unit_type %in% 'imperial')
		temp$distance <- temp$distance * 0.621371

	# xy lims
	bbox <- ggmap::make_bbox(temp$lon, temp$lat, f = f)
	
	# map and base plot
	map <- suppressWarnings(suppressMessages(ggmap::get_map(bbox, maptype = maptype)))
	pbase <- ggmap::ggmap(map) +
		ggplot2::coord_fixed(ratio = 1) +
		ggplot2::theme(axis.title = ggplot2::element_blank())
	
	# add elevation to plot
	if(add_elev){
		
		# check if key provided
		if(is.null(key))
			stop('Google API key is required if plotting elevation')

		# get elevation
		ele <- try({
			rgbif::elevation(latitude = temp$lat, longitude = temp$lon, key = key)$elevation
		})
		if(class(ele) %in% 'try-error')
			stop('Elevation not retrieved, check API key')
		temp$ele <- ele
		temp$ele <- pmax(0, temp$ele)
		
		# change units if imperial
		if(unit_type %in% 'imperial'){
		
			temp$ele <- temp$ele *  3.28084
		
		}
		
		# get gradient
		temp <- dplyr::mutate(temp, EleDiff = c(0, diff(ele)),
									 distdiff = c(0, diff(distance)),
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
	
	# plot distances
	if(dist){
		
		# get distances closes to integers, add final distance
		disttemp <- temp %>% 
			dplyr::mutate(
				tosel = round(distance, distval), 
				diffdist = abs(distance - tosel)
			) %>% 
			dplyr::group_by(activity, tosel) %>% 
			dplyr::filter(diffdist == min(diffdist)) %>% 
			dplyr::ungroup(.) %>% 
			dplyr::select(-tosel, -diffdist) %>% 
			dplyr::mutate(distance = as.character(round(distance)))
		# final <- temp[nrow(temp), ] 
		# final$distance <- format(final$distance, nsmall = 1, digits = 1)
		# disttemp <- rbind(disttemp, final)
	
		# add to plot
		p <- p + 
			ggrepel::geom_label_repel(
				data = disttemp, 
				ggplot2::aes(x = lon, y = lat, label = distance),
				point.padding = grid::unit(0.4, "lines")
				)
		
	}
	
	return(p)
	
}
