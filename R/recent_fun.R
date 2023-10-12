#' Get last three recent activities
#'
#' Get last three recent activities, used internally in \code{\link{athl_fun}}
#' 
#' @param prsd parsed input list
#' 
#' @export
#' 
#' @concept notoken
#' 
#' @return  A data frame of recent activities for the athlete.  An empty list is returned if none found. 
recent_fun <- function(prsd){
	
	recent <- prsd %>%
		rvest::html_elements(".RecentActivities_card__oYIGT")
	
	if(length(recent) == 0)
		return(NA)
	
	out <- list()
	out$name <- rvest::html_elements(recent, ".RecentActivities_title__wXGAv") %>% xml2::xml_text()
	out$date <- rvest::html_elements(recent, ".RecentActivities_timestamp__pB9a8") %>% xml2::xml_text()
	out$labs <- rvest::html_elements(recent, ".Stat_statLabel___khR4") %>% xml2::xml_text()
	out$stats <- rvest::html_elements(recent, ".ActivityStats_statValue__8IGVY") %>% xml2::xml_text()
		
	# matrix(out$stats, ncol = length(out$date), byrow = T)
	return(out)
	
}
