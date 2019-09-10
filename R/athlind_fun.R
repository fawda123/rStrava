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
#' @return 	A list with elements for the athlete name, location, units of measurement, monthly data, recent activities, and achievements.
athlind_fun <- function(athl_num){
	
	# get unparsed url text using input
	url_in <- paste0('https://www.strava.com/athletes/', athl_num)

	# get page data for athlete, parsed as list
	prsd <- url_in %>% 
		read_html() %>% 
		rvest::html_nodes("[data-react-class]") %>%
		xml_attr('data-react-props') %>%
		V8::v8()$get(.)
	
	# exit if nothing found
	if(is.null(prsd)){
		out <- paste0('No data for athlete ', athl_num, ', sharing permissions likely set to private.')
		return(out)
	}
	
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
