#' Get data for a single athlete
#'
#' Get data for a single athlete by web scraping, does not require authentication.  

#' @param athl_num numeric athlete id used by Strava
#'
#' @import RCurl XML xml2
#' 
#' @concept notoken
#' 
#' @export
#' 
#' @return 	A list with elements for the athlete id, units of measurement, location, monthly data, year-to-date data, and an all-time summary.
athlind_fun <- function(athl_num){
	
	# get unparsed url text using input
	url_in <- paste0('https://www.strava.com/athletes/', athl_num)

	# get page data for athlete, parsed as list
	prsd <- url_in %>% 
		read_html() %>% 
		rvest::html_nodes("[data-react-class]") %>%
		xml_attr('data-react-props') %>%
		V8::v8()$get(.)

	# name
	name <- prsd$athlete$name

	# get athlete location
	loc <- location_fun(prsd)
	
	# get units of measurement
	unts <- units_fun(prsd)

	# monthly data from bar plot
	monthly <- monthly_fun(prsd)
	
	# recent activities
	recent <- recent_fun(prsd)
	
	# achievements
	achievements <- achievement_fun(prsd)

	# output
	out <- list(
		name = name,
		location = loc, 
		units = unts, 
		monthly = monthly, 
		recent= recent,
		achievements = achievements
	)
	
	return(out)
	
}
