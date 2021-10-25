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
	
	out <- prsd$athlete$location
	
	if(out == '') 
		out <- NA
	
	return(out)
	
}
