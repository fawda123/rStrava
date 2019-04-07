#' Get last three recent activities
#'
#' Get last three recent activities, used internally in \code{\link{athl_fun}}
#' 
#' @param prsd parsed input list
#' 
#' @export
#' 
#' @concept notoken
recent_fun <- function(prsd){
	
	out <- prsd$recentActivities[, c('id', 'name', 'type', 'startDateLocal', 'distance', 'elevation', 'movingTime')]
	out$distance <- as.numeric(gsub('^(.*)\\s.*$', '\\1', out$distance))
	out$elevation <- as.numeric(gsub('^(.*)\\s.*$', '\\1', out$elevation))
	out$startDateLocal <- as.Date(out$startDateLocal, '%B %d, %Y')

	return(out)
	
}
