#' Generate the ratelimit indicator
#' 
#' Checks the ratelimit values after the last request and stores the left requests in a global variable.
#'
#' @param req value returned from the \code{\link[httr]{GET}} function, used internally in other functions 
#'
#' @details Requests to the Strava API are rate-limited. The default rate limit allows 600 requests every 15 minutes, with up to 30,000 requests per day.  See the documentation at \url{https://strava.github.io/api/#access}. 
#' 
#' @return A global variable \code{usage_left} shows the current limits.
#'
#' @export
#'
#' @concept token
ratelimit <- function(req){
	
	limit <- as.integer(strsplit(req$headers$`x-ratelimit-limit`, ",")[[1]])
	usage <- as.integer(strsplit(req$headers$`x-ratelimit-usage`, ",")[[1]])
	usage_left <<- limit - usage
	
}