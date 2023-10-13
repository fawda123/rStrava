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
#' @return A data frame of recent achievements for the athlete.  An empty list is returned if none found. 
achievement_fun <- function(prsd){
	
	achieve <- rvest::html_elements(prsd, ".Achievements_title__uBr_B")

	if(length(achieve) == 0)
		return(list())
	
	dts <- rvest::html_elements(prsd, '.timeago') %>% xml2::xml_text()
	achieve <- achieve %>% xml2::xml_text()
	
	out <- data.frame(Date = dts, Achievement = achieve)
	
	return(out)
	
}
