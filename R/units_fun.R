#' Get units of measurement
#'
#' Get units of measurement, used internally in \code{\link{athl_fun}}
#' 
#' @param prsd parsed input list
#' 
#' @export
#' 
#' @concept notoken
#' 
#' @return A character vector indicating the units for distance used by the athlete
units_fun <- function(prsd){

	dist <- prsd$recentActivities$distance
	dist <- unique(gsub('^.*\\s(.*)$', '\\1', dist))
	elev <- prsd$recentActivities$elevation
	elev <- unique(gsub('^.*\\s(.*)$', '\\1', elev))
	uni_val <- c(dist, elev)
	
	return(uni_val)
	
}
