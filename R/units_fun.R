#' Get units of measurement
#'
#' Get units of measurement, used internally in \code{\link{athl_fun}}
#' 
#' @param xml_in input HTMLInternalDocument from \code{\link[RCurl]{getURL}}
#'
#' @import XML
#' 
#' @concept notoken
units_fun <- function(xml_in){
	
	uni_val <- xpathSApply(xml_in, "//abbr[@class='unit']", xmlValue)
	uni_val <- unique(uni_val)
	
	return(uni_val)
	
}
