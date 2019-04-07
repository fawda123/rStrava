#' Get distances for last twelve months
#'
#' Get distances for last twelve months, used internally in \code{\link{athl_fun}}
#' 
#' @param prsd parsed input list
#' 
#' @export
#' 
#' @concept notoken
monthly_fun <- function(prsd){
	
	out <- prsd$stats$chartData
	out$month <- as.Date(out$month, format = '%Y-%m-%d')
	
	return(out)
	
}
