#' Create elevation profiles from activity data
#' 
#' Create elevation profiles from activity data
#' 
#' @author Daniel Padfield, Marcus Beck
#' 
#' @concept token
#' 
#' @param act_data an \code{actlist} object returned by \code{\link{get_activity_list}} or a \code{data.frame} returned by \code{\link{compile_activities}}
#' @param acts numeric value indicating which elements of \code{act_data} to plot, defaults to most recent
#' @param key chr string of Google API key for elevation data, passed to \code{\link[rgbif]{elevation}}, see details
#' @param total logical indicating if elevations are plotted as cumulative climbed by distance
#' @param expand a numeric multiplier for expanding the number of lat/lon points on straight lines.  This can create a smoother elevation profile. Set \code{expand = 1} to suppress this behavior.  
#' @param units chr string indicating plot units as either metric or imperial
#' @param ... arguments passed to or from other methods
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
#' 
#' # compile first, change units
#' my_acts <- compile_activities(my_acts, acts = c(1:2), units = 'imperial')
#' get_elev_prof(my_acts, key = mykey)
#' }
#' @export
get_elev_prof <- function(act_data, ...) UseMethod('get_elev_prof')

#' @rdname get_elev_prof
#'
#' @export
#'
#' @method get_elev_prof list
get_elev_prof.list <- function(act_data, acts = 1, key, total = FALSE, expand = 10, units = 'metric', ...){

	# compile
	act_data <- compile_activities(act_data, acts = acts, units = units)
	
	get_elev_prof.actframe(act_data, key = key, total = total, expand = expand, ...)
	
}

#' @rdname get_elev_prof
#'
#' @export
#'
#' @method get_elev_prof actframe
get_elev_prof.actframe <- function(act_data, key, total = FALSE, expand = 10, ...){
	
	# get unit types and values attributes
	unit_type <- attr(act_data, 'unit_type')
	unit_vals <- attr(act_data, 'unit_vals')
	
	# create a dataframe of long and latitudes
	lat_lon <- get_all_LatLon(id_col = 'upload_id', parent_data = act_data) %>%
	  dplyr::full_join(., act_data, by = 'upload_id') %>%
	  dplyr::select(., upload_id, type, start_date, lat, lon, total_elevation_gain)

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
	
	# total elevation gain needs to be numeric for unit conversion
	lat_lon$total_elevation_gain <- round(as.numeric(as.character(lat_lon$total_elevation_gain)), 1)
	
	# get distances
	distances <- dplyr::group_by(lat_lon, upload_id) %>%
	  dplyr::do(data.frame(distance = get_dists(.)))
	lat_lon$distance <- distances$distance
	
	# adding elevation using rgbif
	lat_lon$ele <- rgbif::elevation(latitude = lat_lon$lat, longitude = lat_lon$lon, key = key)$elevation
	lat_lon$ele <- pmax(0, lat_lon$ele)
	
	# axis labels
	ylab <- paste0('Elevation (', unit_vals['elevation'], ')')
	xlab <- paste0('Distance (', unit_vals['distance'], ')')
	
	# change units if imperial
	if(unit_type %in% 'imperial'){

		lat_lon <- dplyr::mutate(lat_lon, 
			ele = ele * 3.28084, 
			distance = distance * 0.621371
		)
		
	}
	
	# format date, total_elevation_gain, create facet labels
	lat_lon <- dplyr::mutate(lat_lon,
		start_date = gsub('T.*$', '', start_date),  
		start_date = as.Date(start_date, format = '%Y-%m-%d'),
		total_elevation_gain = paste('Elev. gain', total_elevation_gain)
		) %>% 
		tidyr::unite('facets', upload_id, start_date, total_elevation_gain, sep = ', ')
	
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
	  ggplot2::xlab(xlab)
	
	return(p)
	
}