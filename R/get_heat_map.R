#' Makes a heat map from your activity data
#' 
#' Makes a heat map from your activity data
#' @author Daniel Padfield
#' @concept posttoken
#' @param act_data a dataframe of Strava activities derived from \code{\link{compile_activities}}
#' @param alpha the opacity of the line desired. A single activity should be 1. Defaults to 0.25
#' @details uses \code{\link{get_all_LatLon}} to produce a dataframe of latitudes and longitudes to use in the map. Uses \code{\link{ggmap}{get_all_LatLon}} to produce map and plot it in \code{\link{ggplot2}}
#' @return plot of activity on a Google map
#' @examples 
#' \dontrun{
#' stoken <- httr::config(ttoken = strava_oauth(app_name, app_client_id, app_secret, cache = TRUE))
#' 
#' acts <- get_activity_list(stoken, 2837007)
#' 
#' acts_data <- compile_activities(acts)
#' 
#' get_heat_map(acts_data[1,], alpha = 1)
#' }

get_heat_map <- function(act_data, alpha = seq(0,1,0.05)){
	if(missing(alpha)){alpha <- 0.25}
	temp <- get_all_LatLon('map.summary_polyline', act_data)
	temp <- tidyr::separate(temp, latlon, c('lat', 'lon'), sep = ',')
	temp <- dplyr::mutate_at(temp, c('lat', 'lon'), as.numeric)
	xlim <- c(min(temp$lon) - 0.1, max(temp$lon + 0.1))
	ylim <- c(min(temp$lat) - 0.1, max(temp$lat + 0.1))
	bbox <- ggmap::make_bbox(temp$lon, temp$lat, f = 0.15)
	map <- suppressMessages(ggmap::get_map(bbox))
	print(ggmap::ggmap(map, extent = 'device') +
					ggplot::coord_cartesian() +
					ggplot::geom_path(aes(x = lon, y = lat, group = map.summary_polyline), col = 'red', alpha = alpha, data = temp, size = 0.5))
}