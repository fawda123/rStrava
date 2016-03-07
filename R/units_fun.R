#' Get units of measurement
#'
#' Get units of measurement, used internally in \code{\link{athl_fun}}
#' 
#' @param xml_in input HTMLInternalDocument from \code{\link[RCurl]{getURL}}
#'
#' @import XML
#' 
#' @export
#' 
#' @concept notoken
units_fun <- function(xml_in){

	uni_val <- xpathSApply(xml_in, "//abbr[@class='unit']", xmlValue)
	uni_val <- uni_val[1:4]
	
	return(uni_val)
	
}
