#' get latitude and longitude for multiple activities
#' 
#' get latitude and longitude for multiple activities
#' @param id_col the column that you want to be used as an identifier for the dataframe of latitude and longitude coordinates
#' @param parent_data the dataframe that contains the Strava activity data
#' @return dataframe of latitude and longitudes with a column for each unique identifier
#' @author Daniel Padfield
#' @concept posttoken
#' @details uses \code{\link{get_all_LatLon}} and \code{\link{decode_Polyline}} to produce a dataframe of latitudes and longitudes
#' @examples
#' \dontrun{
#' get_all_LatLon('upload_id', acts_data)
#' }
#' @export


get_all_LatLon <- function(id_col, parent_data){
	id_col_fac <- as.factor(parent_data[,id_col])
	temp <- split(parent_data, id_col_fac)
	temp_data <- plyr::ldply(temp, get_LatLon, .id_col = id_col)
	data <- temp_data[,c(3, 2)]
	return(data)
}