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

	nms <- rvest::html_elements(recent, ".RecentActivities_titleButton__1Uq_v") %>% xml2::xml_text()
	dts <- rvest::html_elements(recent, ".RecentActivities_timestamp__pB9a8") %>% xml2::xml_text()
	lbs <- rvest::html_elements(recent, ".Stat_statLabel___khR4") %>% xml2::xml_text()
	stats <- rvest::html_elements(recent, ".ActivityStats_statValue__8IGVY") %>% 
		xml2::xml_text() %>% 
		matrix(nrow = length(recent), byrow = TRUE) %>% 
		as.data.frame()
	lbs <- lbs[1:ncol(stats)]
	names(stats) <- lbs
	stats$Date <- dts
	stats$Name <- nms
	
	out <- stats[, c('Date', 'Name', lbs)]
		
	return(out)
	
}
