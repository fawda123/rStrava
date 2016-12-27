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
#' @import magrittr
#' 
#' @return A vector of distances with the length as the number of rows in \code{dat_in}
#' 
#' @examples
#' \dontrun{
#' # get activity data
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, app_secret, cache = TRUE))
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
#' @export
get_dists <- function(dat_in, lon = 'lon', lat = 'lat'){
  
	dat <- dat_in[,c('activity', lon, lat)]
  names(dat) <- c('activity', 'lon', 'lat')
  
	# distances by activity
  out <- split(dat, dat$activity)
  out <- lapply(out, function(x){
  	
  	x <- x[, c('lon', 'lat')]
  	x <- sapply(2:nrow(x), function(y){geosphere::distm(x[y-1,], x[y,])/1000})
  
  	return(c(0, cumsum(x)))
  
  })
  	
  out <- as.numeric(unlist(out))
  
  return(out)
  
}