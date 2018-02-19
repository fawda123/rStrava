#' get latitude and longitude from Google polyline
#'
#' get latitude and longitude from Google polyline 
#' 
#' @param x the dataframe that contains the Strava activity data
#' @author Daniel Padfield
#' @concept token
#' @return dataframe of latitude and longitudes with a column for the unique identifier
#' @examples
#' \dontrun{
#' getlatlon(act, 'upload_id')
#' }
#' @export
get_latlon <- function(x){
	if('map.summary_polyline' %in% names(x)){y <- decode_Polyline(x$map.summary_polyline)}
	if('map.polyline' %in% names(x)){y <- decode_Polyline(x$map.polyline)}
	
	y <- tidyr::separate(y, latlon, c('lat', 'lon'), sep = ',')
	y <- dplyr::mutate_at(y, c('lat', 'lon'), as.numeric)
	
	return(y)
}
