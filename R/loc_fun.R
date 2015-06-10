#' Get athlete location
#'
#' Get location of an athlete, used internally in \code{\link{athl_fun}}
#' 
#' @param xml_in input HTMLInternalDocument from \code{\link[RCurl]{getURL}}
#'
#' @import XML
#' 
#' @concept notoken
loc_fun <- function(xml_in){
	
	loc_val <- xpathSApply(xml_in, "//div[@class='location']", xmlValue)
	loc_val <- gsub('\\n|[[:space:]]*$', '', loc_val)
	
	return(loc_val)
	
}
