#' Get data for a single athlete
#'
#' Get data for a single athlete by web scraping, does not require authentication.  

#' @param athl_num numeric athlete id used by Strava
#'
#' @import RCurl XML
#' 
#' @concept notoken
#' 
#' @export
#' 
#' @return 	A list with elements for the athlete id, units of measurement, location, monthly data, year-to-date data, and an all-time summary.
athlind_fun <- function(athl_num){
	
	# get unparsed url text using input
	url_in <- paste0('https://www.strava.com/athletes/', athl_num)
	
	# get page data for athlete
	athl_url <- try(GET(url_in), silent = TRUE)

	# url as HTMLInternalDoc
	prsd <- htmlTreeParse(athl_url, useInternalNodes = TRUE)

	# get units of measurement
	unts <- units_fun(prsd)
	
	# get athlete location
	loc <- loc_fun(prsd)
	
	prsd <- list(parsed = prsd, units = unts, location = loc)
	
	# monthly data from bar plot
	monthly <- monthly_fun(prsd)
	
	# year to date and all time summary
	summ <- summ_fun(prsd)

	# output
	out <- list(
		units = unts, 
		location = loc, 
		current_month = summ[['current_month']],
		monthly = monthly, 
		year_to_date = summ[['year_to_date']],
		all_time = summ[['all_time']]
	)
	return(out)
	
}
