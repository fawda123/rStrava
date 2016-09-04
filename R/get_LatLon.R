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
#' @export
get_LatLon <- function(x, .id_col){
	y <- decode_Polyline(x$map.summary_polyline)
	y[,id_col] <- unique(x[,.id_col])
	return(y)
}