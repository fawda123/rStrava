#' Get distance and time for current month
#'
#' Get distance and time for current month, used internally in \code{\link{athl_fun}}
#' 
#' @param prsd parsed input list
#' 
#' @export
#' 
#' @concept notoken
#' 
#' @return  A data frame of the current monthly distance and time for the athlete. An empty list is returned if none found.
monthly_fun <- function(prsd){

	mos <- prsd %>% 
		rvest::html_elements('.MonthlyStats_monthlyStats__5VwJ_')
	
	if(length(mos) == 0)
		return(list())

	labs <- mos %>% 
		rvest::html_elements('.Stat_statLabel___khR4') %>% 
		xml2::xml_text()
	vals <- mos %>% 
		rvest::html_elements('.Stat_statValue__3_kAe') %>% 
		xml2::xml_text()

	out <- data.frame(matrix(vals, ncol = length(vals)))
	names(out) <- labs
	
	return(out)
	
}
