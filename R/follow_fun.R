#' Get athlete follow data
#'
#' Get athlete follow data, used internally in \code{\link{athl_fun}}
#' 
#' @param prsd parsed input list
#' 
#' @export
#' 
#' @concept notoken
#' 
#' @return  A data frame of counts of followers and following for the athlete. An empty list is returned if none found.
follow_fun <- function(prsd){
	
	follow <- prsd %>%
		rvest::html_elements(".Details_followStats__Pwe6T")
	
	if(length(follow) == 0)
		return(list())
	
	labs <- follow %>% 
		rvest::html_elements(".Stat_statLabel___khR4") %>% 
		xml2::xml_text()
	fols <- follow %>% 
		rvest::html_elements(".Stat_statValue__3_kAe") %>% 
		xml2::xml_text()
	
	out <- data.frame(matrix(fols, ncol = length(labs)))
	names(out) <- labs
	
	return(out)
	
}
