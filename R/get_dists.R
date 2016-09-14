#' Get distance from longitude and latitude points
#' 
#' Get distance from longitude and latitude points
#' 
#' @param dat_in input data frame
#' @param lon chr string indicating name of longitude column in \code{dat_in}
#' @param lat chr string indicating name of latitude column in \code{dat_in}
#' 
#' @author Daniel Padfield
#'
#' @details Used internally in \code{\link{get_elev_prof}} on objects returned by \code{\link{get_all_LatLon}}
#' 
#' @concept token
#' 
#' @return A vector of distances with the length as the number of rows in \code{dat_in}
#' 
#' @examples
#' \dontrun{
#' # get activity data
#' stoken <- httr::config(ttoken = strava_oauth(app_name, app_client_id, app_secret, cache = TRUE))
#' my_acts <- get_activity_list(stoken)
#' 
#' # get the latest activity
#' acts_data <- compile_activities(my_acts)[1, ]
#' 
#' # get lat, lon
#' latlon <- get_all_LatLon('map.summary_polyline', acts_data)
#' 
#' # get distance
#' get_dists(latlon)
#' }
get_dists <- function(dat_in, lon = 'lon', lat = 'lat'){
  
	dat <- dat_in[,c(lon, lat)]
  names(dat) <- c('lon', 'lat')
  
	# column for distance
  x <- sapply(2:nrow(dat_in), function(y){geosphere::distm(dat[y-1,], dat[y,])/1000})
  
  return(c(0, cumsum(x)))
  
}