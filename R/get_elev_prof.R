#' Create elevation profiles from activitiy data
#' 
#' Create elevation profiles from activitiy data
#' 
#' @author Daniel Padfield
#' 
#' @concept token
#' 
#' @param act_data a list of Strava activities derived from \code{\link{get_activity_list}}
#' @param acts numeric value indicating which elements of \code{act_data} to plot, defaults to most recent
#' @param key chr string of Google API key for elevation data, passed to \code{\link[rgbif]{elevation}}, see details
#' @param total logical indicating if elevations are plotted as cumulative climbed by distance
#' @param expand a numeric multiplier for expanding the number of lat/lon points on straight lines.  This can create a smoother elevation gradient if \code{add_grad = TRUE}.  Set \code{expand = 1} to suppress this behavior.  
#' 
#' @details The Google API key is easy to obtain, follow instructions here: https://developers.google.com/maps/documentation/elevation/#api_key
#' 
#' @return A \code{ggplot} of elevation profiles, facetted by activity id, date
#' 
#' @importFrom magrittr %>%
#' 
#' @seealso \code{\link{get_dists}}
#' 
#' @examples
#' \dontrun{
#' # get my activities
#' stoken <- httr::config(ttoken = strava_oauth(app_name, app_client_id, app_secret, cache = TRUE))
#' my_acts <- get_activity_list(stoken)
#' 
#' # your unique key
#' mykey <- 'Get Google API key'
#' get_elev_prof(my_acts, acts = 1:2, key = mykey)
#' }
#' @export
get_elev_prof <- function(act_data, acts = 1, key, total = FALSE, expand = 10){

	# compile
	MyActs <- compile_activities(act_data[acts])
	
	# create a dataframe of long and latitudes
	lat_lon <- get_all_LatLon(id_col = 'upload_id', parent_data = MyActs) %>%
	  dplyr::full_join(., MyActs, by = 'upload_id') %>%
	  dplyr::select(., upload_id, type, start_date, lat, lon, location_city, total_elevation_gain) %>% 
		mutate(total_elevation_gain = paste('Elev. gain', total_elevation_gain))

	# expand lat/lon for each activity
	lat_lon <- split(lat_lon, lat_lon$upload_id)
	lat_lon <- lapply(lat_lon, function(x) {
	
		xint <- stats::approx(x = x$lon, n = expand * nrow(x))$y
		yint <- stats::approx(x = x$lat, n = expand * nrow(x))$y
		data.frame(
			upload_id = unique(x$upload_id), 
			start_date = unique(x$start_date), 
			total_elevation_gain = unique(x$total_elevation_gain),
			lat = yint, 
			lon = xint
			)
		
	})
	lat_lon <- do.call('rbind', lat_lon)
	
	# get distances
	distances <- dplyr::group_by(lat_lon, upload_id) %>%
	  dplyr::do(data.frame(distance = get_dists(.)))
	lat_lon$distance <- distances$distance
	
	# adding elevation using rgbif
	lat_lon$ele <- rgbif::elevation(latitude = lat_lon$lat, longitude = lat_lon$lon, key = key)$elevation
	lat_lon$ele <- pmax(0, lat_lon$ele)
	
	lat_lon$start_date <- gsub('T.*$', '', lat_lon$start_date) %>% 
		as.Date(format = '%Y-%m-%d')
	lat_lon <- tidyr::unite(lat_lon, 'facets', upload_id, start_date, total_elevation_gain, sep = ', ')

	ylab <- 'Elevation (m)'
	
	# get total climbed over distance
	if(total){
		
		lat_lon <- dplyr::group_by(lat_lon, facets) %>% 
			dplyr::mutate(ele = c(0, cumsum(pmax(0, diff(ele)))))
		ylab <- paste('Total', ylab)
	}
		
	p <- ggplot2::ggplot(data = lat_lon, ggplot2::aes(x = distance)) +
	  ggplot2::geom_ribbon(ggplot2::aes(ymax = ele, ymin = min (ele) - ((max(ele) - min(ele))/5)), fill = 'dark blue') +
	  ggplot2::theme_bw() +
		ggplot2::facet_wrap(~facets, ncol = 1) + 
	  ggplot2::ylab(ylab) +
	  ggplot2::xlab('Distance (km)')
	
	return(p)
	
}