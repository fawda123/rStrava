#' get latitude and longitude from Google polyline
#'
#' get latitude and longitude from Google polyline 
#' 
#' @param x the dataframe that contains the Strava activity data
#' @param .id_col the column that you want to be used as an identifier for the dataframe of latitude and longitude coordinates
#' @author Daniel Padfield
#' @details used internally in \code{\link{get_all_LatLon}}
#' @concept token
#' @return dataframe of latitude and longitudes with a column for the unique identifier
#' @examples
#' \dontrun{
#' getLatLon(act, 'upload_id')
#' }
#' @export
get_LatLon <- function(x, .id_col){
	if('map.summary_polyline' %in% names(x)){y <- decode_Polyline(x$map.summary_polyline)}
	if('map.polyline' %in% names(x)){y <- decode_Polyline(x$map.polyline)}
	
	y[,.id_col] <- unique(x[,.id_col])
	return(y)
}
