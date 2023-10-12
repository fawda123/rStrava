#' Get athlete location
#'
#' Get athlete location, used internally in \code{\link{athl_fun}}
#' 
#' @param prsd parsed input list
#' 
#' @export
#' 
#' @concept notoken
#' 
#' @return A character string of the athlete location
location_fun <- function(prsd){
	
	out <- prsd %>% 
		rvest::html_elements(".Details_location__2Dwwo") %>% 
		xml2::xml_text()
	
	if(length(out) == 0) 
		out <- NA
	
	return(out)
	
}
