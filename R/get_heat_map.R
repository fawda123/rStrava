#' Makes a heat map from your activity data
#' 
#' Makes a heat map from your activity data
#' 
#' @author Daniel Padfield
#' 
#' @concept token
#' 
#' @param act_data a dataframe of Strava activities derived from \code{\link{compile_activities}}
#' @param acts numeric indicating which activities to plot based on index in \code{act_data}, defaults to most recent
#' @param alpha the opacity of the line desired. A single activity should be 1. Defaults to 0.5
#' @param f number specifying the fraction by which the range should be extended for the bounding box of the activities, passed to \code{\link[ggmap]{make_bbox}}
#' @param add_grad logical indicating if gradient is overlayed by color shading on the activity lines
#' @param key chr string of Google API key for elevation data, passed to \code{\link[rgbif]{elevation}}, see details
#' @param size numeric indicating width of activity lines
#' @param col chr string indicating either a single color of the activity lines if \code{add_grad = FALSE} or a color palette passed to \code{\link[ggplot2]{scale_fill_distiller}} if \code{add_grad = TRUE}
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
#' get_heat_map(my_acts[1], alpha = 1, key = mykey, add_grad = TRUE)
#' }
get_heat_map <- function(act_data, acts = 1, alpha = NULL, f = 1, add_grad = FALSE, key = NULL, size = 0.5, col = 'red'){
	
	if(is.null(alpha)) alpha <- 0.5
	
	# compile
	act_data <- compile_activities(act_data[acts])
	
	# data to plot
	temp <- get_all_LatLon('map.summary_polyline', act_data)
	
	# xy lims
	xlim <- c(min(temp$lon), max(temp$lon))
	ylim <- c(min(temp$lat), max(temp$lat))
	bbox <- ggmap::make_bbox(temp$lon, temp$lat, f = f)
	
	# map and base plot
	map <- suppressWarnings(suppressMessages(ggmap::get_map(bbox)))
	pbase <- ggmap::ggmap(map) +
		ggplot2::coord_equal() +
		ggplot2::theme(axis.title = ggplot2::element_blank())
	
	# add elevation to plot
	if(add_grad){
		
		# check if key provided
		if(is.null(key))
			stop('Google API key is required if plotting elevation')
		
		# get elevation
		temp$`Elevation (m)` <- rgbif::elevation(latitude = temp$lat, longitude = temp$lon, key = key)$elevation
		temp <- mutate(temp, EleDiff = c(0, diff(`Elevation (m)`)),
									 distdiff = c(0, diff(rStrava::get_dists(temp))),
									 grad = c(0, (EleDiff[2:nrow(temp)]/10)/distdiff[2:nrow(temp)]))
		
		
		p <- pbase +
			ggplot2::geom_path(ggplot2::aes(x = lon, y = lat, group = map.summary_polyline, colour = grad), 
												 alpha = alpha, data = temp, size = size) +
			ggplot2::scale_colour_distiller('Gradient (%)', palette = col, trans = 'reverse')
		
		# otherwise dont		
	} else {
		
		p <- pbase +
			ggplot2::geom_path(ggplot2::aes(x = lon, y = lat, group = map.summary_polyline), 
												 alpha = alpha, data = temp, size = size, colour = col)
		
	}
	
	return(p)
	
}
