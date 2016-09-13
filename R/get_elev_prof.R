#' Create elevation profiles from activitiy data
#' 
#' Create elevation profiles from activitiy data
#' 
#' @author Daniel Padfield
#' 
#' @concept token
#' 
#' @param act_data a list of Strava activities derived from \code{\link{get_activity_list}}
#' @param acts numeric value indicating which elements of \code{act_data} to plot
#' @param key chr string of Google API key for elevation data, passed to \code{\link[rgbif]{elevation}}, see details
#' 
#' @details The Google API key is easy to obtain, follow instructions here: https://developers.google.com/maps/documentation/elevation/#api_key
#' 
#' @return A \code{ggplot} of elevation profiles, facetted by activity id, date
#' 
#' @importFrom magrittr %>%
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
get_elev_prof <- function(act_data, acts = 1, key){

	# compile
	MyActs <- compile_activities(act_data[acts])
	
	# create a dataframe of long and latitudes
	lat_lon <- get_all_LatLon(id_col = 'upload_id', parent_data = MyActs) %>%
	  dplyr::full_join(., MyActs, by = 'upload_id') %>%
	  dplyr::select(., upload_id, type, start_date, latlon, location_city) %>%
	  tidyr::separate(., latlon, c('lat', 'lon'), sep = ',') %>%
	  dplyr::mutate_at(., c('lat', 'lon'), as.numeric) 
	
	# function for working out distance from longitude and latitude points ###
	distance <- function(data, lon, lat){
	  dat <- data[,c(lon, lat)]
	  # column for distance
	  x <- sapply(2:nrow(dat), function(y){geosphere::distm(dat[y-1,], dat[y,])/1000})
	  return(c(0, cumsum(x)))
	}
	
	distances <- dplyr::group_by(lat_lon, upload_id) %>%
	  dplyr::do(data.frame(distance = distance(.,  'lon', 'lat')))
	lat_lon$distance <- distances$distance

	# adding elevation using rgbif
	lat_lon$ele <- rgbif::elevation(latitude = lat_lon$lat, longitude = lat_lon$lon, key = key)$elevation

	lat_lon$start_date <- gsub('T.*$', '', lat_lon$start_date) %>% 
		as.Date(format = '%Y-%m-%d')
	lat_lon <- tidyr::unite(lat_lon, 'facets', upload_id, start_date, sep = ', ')

	p <- ggplot2::ggplot(data = lat_lon, ggplot2::aes(x = distance)) +
	  ggplot2::geom_ribbon(ggplot2::aes(ymax = ele, ymin = min (ele) - ((max(ele) - min(ele))/5)), fill = 'dark blue') +
	  ggplot2::theme_bw() +
		ggplot2::facet_wrap(~facets, ncol = 1) + 
	  ggplot2::ylab('Elevation (m)') +
	  ggplot2::xlab('Distance (km)')
	
	return(p)
	
}