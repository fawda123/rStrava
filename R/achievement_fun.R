#' Get recent achievements
#'
#' Get recent achievements, used internally in \code{\link{athl_fun}}
#' 
#' @param prsd parsed input list
#' 
#' @export
#' 
#' @concept notoken
#' 
#' @return A data frame of recent achievements for the athlete.  An empty list is returned if none found 
achievement_fun <- function(prsd){
	
	if(length(prsd$achievements) == 0)
		return(list())
	
	out <- prsd$achievements[, c('description', 'timeago')]
	out$timeago <- gsub('^.*\"timeago\"\\sdatetime=\\"(.*Z)\\".*$', '\\1', out$timeago)
	out$timeago <- as.POSIXct(gsub('T|Z', ' ', out$timeago), 'GMT')
	
	return(out)
	
}
