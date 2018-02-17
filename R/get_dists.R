#' Get distance from longitude and latitude points
#' 
#' Get distance from longitude and latitude points
#' 
#' @param lon chr string indicating name of longitude column in \code{dat_in}
#' @param lat chr string indicating name of latitude column in \code{dat_in} in \code{dat_in}
#' 
#' @author Daniel Padfield
#'
#' @details Used internally in \code{\link{get_elev_prof}} on objects returned by \code{\link{get_latlon}}
#' 
#' @concept notoken
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
#' get_dists(latlon$lon, latlon$lat)
#' }
#' @export
get_dists <- function(lon, lat){
  
	dat <- tibble::tibble(lon, lat)
  names(dat) <- c('lon', 'lat')
  
	# distances by activity
  out <- sapply(2:nrow(dat), function(y){geosphere::distm(dat[y-1,], dat[y,])/1000})
  out <- 	c(0, cumsum(out))
  return(out)
}