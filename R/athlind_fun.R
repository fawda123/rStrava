#' Get data for a single athlete
#'
#' Get data for a single athlete by web scraping, does not require authentication.  

#' @param athl_num numeric athlete id used by Strava, as character string
#'
#' @import RCurl XML xml2
#' 
#' @concept notoken
#' 
#' @export
#' 
#' @return 	A list with elements for the athlete's information.
athlind_fun <- function(athl_num){
	
	if(any(!is.character(athl_num))) 
		stop('athl_num must be a character vector')
	
	# get unparsed url text using input
	url_in <- paste0('https://www.strava.com/athletes/', athl_num)
	
	# get page data for athlete
	prsd <- url_in %>% 
		read_html()

	# name
	name <- prsd %>%
		rvest::html_elements(".Details_name__Wz5bH") %>% 
		xml2::xml_text()

	# exit if nothing found
	if(length(name) == 0){
		out <- paste0("No data for athlete ", athl_num, ", doesn't exist or sharing set to private.")
		return(out)
	}
	
	# get athlete location
	loc <- location_fun(prsd)

	# get follower data
	follow <- follow_fun(prsd)
	
	# monthly data from bar plot
	monthly <- monthly_fun(prsd)
	
	# recent activities
	recent <- recent_fun(prsd)
	
	# trophies
	trophies <- trophy_fun(prsd)
	
	# achievements
	achievements <- achievement_fun(prsd)
	
	# output
	out <- list(
		name = name,
		location = loc, 
		follow = follow,
		monthly = monthly, 
		recent= recent,
		trophies = trophies,
		achievements = achievements
	)
	
	return(out)
	
}
