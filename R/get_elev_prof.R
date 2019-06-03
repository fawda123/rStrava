#' Create elevation profiles from activity data
#' 
#' Create elevation profiles from activity data
#' 
#' @author Daniel Padfield, Marcus Beck
#' 
#' @concept token
#' 
#' @param act_data an activities list object returned by \code{\link{get_activity_list}} or a \code{data.frame} returned by \code{\link{compile_activities}}
#' @param acts numeric value indicating which elements of \code{act_data} to plot, defaults to most recent
#' @param key chr string of Google API key for elevation data, passed to \code{\link[googleway]{google_elevation}}, see details
#' @param total logical indicating if elevations are plotted as cumulative climbed by distance
#' @param expand a numeric multiplier for expanding the number of lat/lon points on straight lines.  This can create a smoother elevation profile. Set \code{expand = 1} to suppress this behavior.  
#' @param units chr string indicating plot units as either metric or imperial, this has no effect if input data are already compiled with \code{\link{compile_activities}}
#' @param fill chr string of fill color for profile
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
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, app_secret, cache = TRUE))
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
get_elev_prof.list <- function(act_data, acts = 1, key, total = FALSE, expand = 10, units = 'metric', fill = 'darkblue', ...){

	# compile
	act_data <- compile_activities(act_data, acts = acts, units = units)

	get_elev_prof.actframe(act_data, key = key, total = total, expand = expand, fill = fill, ...)
	
}

#' @rdname get_elev_prof
#'
#' @export
#'
#' @method get_elev_prof actframe
get_elev_prof.actframe <- function(act_data, key, total = FALSE, expand = 10, fill = 'darkblue', ...){

	# get unit types and values attributes
	unit_type <- attr(act_data, 'unit_type')
	unit_vals <- attr(act_data, 'unit_vals')
	
	# warning if units conflict
	args <- as.list(match.call())
	if('units' %in% names(args))
		if(args$units != unit_type)
			warning('units does not match unit type, use compile_activities with different units')

	# remove rows without polylines
	act_data <- chk_nopolyline(act_data)
	
	# create a dataframe of long and latitudes
	lat_lon <- act_data %>% 
		dplyr::group_by(upload_id) %>%
		tidyr::nest() %>% 
		mutate(locs = purrr::map(data, function(x) get_latlon(x$map.summary_polyline, key = key))) %>% 
		dplyr::select(-data) %>%
		dplyr::ungroup() %>% 
		tidyr::unnest() %>%
		dplyr::full_join(., act_data, by = 'upload_id') %>%
		dplyr::select(., upload_id, type, start_date, lat, lon, ele, total_elevation_gain)
	
	# total elevation gain needs to be numeric for unit conversion
	lat_lon$total_elevation_gain <- round(as.numeric(as.character(lat_lon$total_elevation_gain)), 1)
	lat_lon$activity <- as.numeric(as.character(lat_lon$upload_id))
	lat_lon$upload_id <- NULL
	
	# get distances
	distances <- dplyr::group_by(lat_lon, activity) %>%
	  dplyr::mutate(., distance = get_dists(lon, lat))
	lat_lon$distance <- distances$distance
	
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
		tidyr::unite('facets', activity, start_date, total_elevation_gain, sep = ', ')
	
	# get total climbed over distance
	if(total){
		
		lat_lon <- dplyr::group_by(lat_lon, facets) %>% 
			dplyr::mutate(ele = c(0, cumsum(pmax(0, diff(ele)))))
		ylab <- paste('Total', ylab)
		
	}
		
	p <- ggplot2::ggplot(data = lat_lon, ggplot2::aes(x = distance)) +
	  ggplot2::geom_ribbon(ggplot2::aes(ymax = ele, ymin = min (ele) - ((max(ele) - min(ele))/5)), fill = fill) +
	  ggplot2::theme_bw() +
		ggplot2::facet_wrap(~facets, ncol = 1) + 
	  ggplot2::ylab(ylab) +
	  ggplot2::xlab(xlab)
	
	return(p)
	
}

#' @rdname get_elev_prof
#'
#' @export
#'
#' @method get_elev_prof strframe
get_elev_prof.strframe <- function(act_data, total = FALSE, expand = 10, fill = 'darkblue', ...){

	# get unit types and values attributes
	unit_type <- attr(act_data, 'unit_type')
	unit_vals <- attr(act_data, 'unit_vals')
	
	# warning if units conflict
	args <- as.list(match.call())
	if('units' %in% names(args))
		if(args$units != unit_type)
			warning('units argument ignored for strframe objects')
	
	# expand lat/lon for each activity
	act_data <- split(act_data, act_data$id)
	act_data <- lapply(act_data, function(x) {

		xint <- stats::approx(x = x$lng, n = expand * nrow(x))$y
		yint <- stats::approx(x = x$lat, n = expand * nrow(x))$y
		elev <- stats::approx(x = x$altitude, n = expand * nrow(x))$y
		dist <- stats::approx(x = x$distance, n = expand * nrow(x))$y
		data.frame(
			activity = unique(x$id), 
			lat = yint, 
			lon = xint, 
			distance = dist,
			ele = pmax(0, elev), 
			total_elevation_gain = round(max(cumsum(diff(elev))))
		)
		
	})
	act_data <- do.call("rbind", act_data)

	# axis labels
	ylab <- paste0('Elevation (', unit_vals['elevation'], ')')
	xlab <- paste0('Distance (', unit_vals['distance'], ')')
	
	# format date, total_elevation_gain, create facet labels
	act_data <- dplyr::mutate(act_data,
													 total_elevation_gain = paste('Elev. gain', total_elevation_gain)
	) %>% 
		tidyr::unite('facets', activity, total_elevation_gain, sep = ', ')

	# get total climbed over distance
	if(total){
		
		act_data <- dplyr::group_by(act_data, facets) %>% 
			dplyr::mutate(ele = c(0, cumsum(pmax(0, diff(ele)))))
		ylab <- paste('Total', ylab)
		
	}
	
	p <- ggplot2::ggplot(data = act_data, ggplot2::aes(x = distance)) +
		ggplot2::geom_ribbon(ggplot2::aes(ymax = ele, ymin = min (ele) - ((max(ele) - min(ele))/5)), fill = fill) +
		ggplot2::theme_bw() +
		ggplot2::facet_wrap(~facets, ncol = 1) + 
		ggplot2::ylab(ylab) +
		ggplot2::xlab(xlab)
	
	return(p)
	
}