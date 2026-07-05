#' Get data for an athlete
#'
#' Get data for an athlete by web scraping, does not require authentication.  

#' @param athl_num numeric vector of athlete id(s) used by Strava, as character string
#' @param trace logical indicating if output is returned to console
#' 
#' @export
#' 
#' @details The athlete id is assigned to the user during registration with Strava and this must be known to use the function.  Some users may have privacy settings that prevent public access to account information (a message indicating as such will be returned by the function). The function scrapes data using the following URL with the appended athlete id, e.g., \url{https://www.strava.com/athletes/2837007}.  Opening the URL in a web browser can verify if the data can be scraped.  Logging in to the Strava account on the website may also be required before using this function.
#' 
#' @concept notoken
#' 
#' @return 	A list for each athlete, where each element is an additional list with elements for the athlete's information.  The list elements are named using the athlete id numbers.
#' 
#' @examples
#' ## single athlete
#' athl_fun('2837007')
#' 
#' \dontrun{
#' ## multiple athletes
#' athl_fun(c('2837007', '2527465'))
#' }
athl_fun <- function(athl_num, trace = TRUE){
	
	if(any(!is.character(athl_num))) 
		stop('athl_num must be a character vector')
	
	# allocate empty list
	out <- vector('list', length(athl_num))
	names(out) <- as.character(athl_num)
		
	# iterate through athletes
	for(val in athl_num){
		
		# progress
		if(trace) cat(val, which(val == athl_num), 'of', length(athl_num), '\n')
		
		# get data
		try_athl <- try(athlind_fun(val))
		
		# output data, NA if doesn't exist
		if('try-error' %in% class(try_athl)) 
			out[[as.character(val)]] <- NA_real_
		else out[[as.character(val)]] <- try_athl
		
	}

	return(out)
	
}
