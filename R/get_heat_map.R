#' Makes a heat map from your activity data
#' 
#' Makes a heat map from your activity data
#' 
#' @author Daniel Padfield
#' 
#' @concept token
#' 
#' @param act_data a dataframe of Strava activities derived from \code{\link{compile_activities}}
#' @param alpha the opacity of the line desired. A single activity should be 1. Defaults to 0.5
#' @param f number specifying the fraction by which the range should be extended for the bounding box of the activities, passed to \code{\link[ggmap]{make_bbox}}
#' 
#' @details uses \code{\link{get_all_LatLon}} to produce a dataframe of latitudes and longitudes to use in the map. Uses {ggmap} to produce map and ggplot2 it
#' 
#' @return plot of activity on a Google map
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
#' get_heat_map(acts_data[1,], alpha = 1)
#' }
get_heat_map <- function(act_data, alpha = NULL, f = 1){
	
	if(is.null(alpha)) alpha <- 0.5
	
	# data to plot
	temp <- get_all_LatLon('map.summary_polyline', act_data)
	temp <- tidyr::separate(temp, latlon, c('lat', 'lon'), sep = ',')
	temp <- dplyr::mutate_at(temp, c('lat', 'lon'), as.numeric)
	
	# xy lims
	xlim <- c(min(temp$lon), max(temp$lon))
	ylim <- c(min(temp$lat), max(temp$lat))
	bbox <- ggmap::make_bbox(temp$lon, temp$lat, f = f)
	
	# map
	map <- suppressWarnings(suppressMessages(ggmap::get_map(bbox)))
	p <- ggmap::ggmap(map) +
					ggplot2::coord_equal() +
					ggplot2::geom_path(ggplot2::aes(x = lon, y = lat, group = map.summary_polyline), col = 'red', alpha = alpha, data = temp, size = 0.5) + 
		ggplot2::theme(axis.title = ggplot2::element_blank())

	return(p)
	
}