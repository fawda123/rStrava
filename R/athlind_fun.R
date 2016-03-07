#' Get data for a single athlete
#'
#' Get data for a single athlete by web scraping, does not require authentication.  

#' @param athl_num numeric athlete id used by Strava
#'
#' @import RCurl XML
#' 
#' @concept notoken
#' 
#' @return 	A list with elements for the athlete id, units of measurement, location, monthly data, year-to-date data, and an all-time summary.
athlind_fun <- function(athl_num){
	
	# get unparsed url text using input
	url_in <- paste0('http://www.strava.com/athletes/', athl_num)
	
	athl_exists <- url.exists(url_in)
	
	if(!athl_exists) stop('Athlete does not exist')
	
	# get page data for athlete
	athl_url <- getURL(url_in)
	
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
