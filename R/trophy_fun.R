#' Get athlete trophies
#'
#' Get athlete trophies, used internally in \code{\link{athl_fun}}
#' 
#' @param prsd parsed input list
#' 
#' @export
#' 
#' @concept notoken
#' 
#' @return  A data frame of trophies for the athlete. An empty list is returned if none found.
trophy_fun <- function(prsd){
	
	# xml_find_all(parsed_xml, './/title')
	trophies <- prsd %>%
		rvest::html_elements(".Trophy_description__EcC86")

	if(length(trophies) == 0)
		return(list())
	
	dts <- rvest::html_elements(prsd, ".Trophy_timestamp__cb9gx") %>% xml2::xml_text()
	trophies <- trophies %>% xml2::xml_text()

	out <- data.frame(Date = dts, Trophy = trophies)
	
	return(out)
	
}
