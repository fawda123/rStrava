#' Get distances for last twelve months
#'
#' Get distances for last twelve months, used internally in \code{\link{athl_fun}}
#' 
#' @param prsd parsed input list
#' 
#' @export
#' 
#' @concept notoken
#' 
#' @return  A data frame of monthly summaries for the athlete, including distance, time, and elevation gain each month.  A \code{NA} value is returned if no activity was observed in recent months. 
monthly_fun <- function(prsd){

	out <- prsd$stats$chartData
	
	if(is.null(out)) 
		return(NA)
	
	out$month <- as.Date(out$month, format = '%Y-%m-%d')
	
	return(out)
	
}
