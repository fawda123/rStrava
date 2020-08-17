#' Format before and after arguments for API query
#'
#' @param dtin Date object for \code{before} or \code{after} inputs
#' @param before logical indicattng if input is \code{before}
#'
#' @return A numeric object as an epoch timestamp 
#' @export
#'
#' @examples
#' # convert to epoch timestamp
#' seltime_fun(Sys.Date())
#' 
#' # back to original 
#' as.POSIXct(seltime_fun(Sys.Date(), before = FALSE), tz = Sys.timezone(), origin = '1970-01-01')
seltime_fun <- function(dtin, before = TRUE){
	
	if(is.null(dtin))
		return()
	
	stopifnot(inherits(dtin, 'Date'))
	
	if(before) tval <- '00:00:00'
	
	if(!before)	tval <- '23:59:59'

	dtin <- paste(as.character(dtin), tval)
	dtin <- as.POSIXct(dtin, tzone = Sys.timezone())
	out<- as.numeric(dtin)

	return(out)
	
}
