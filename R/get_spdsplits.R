#' Get speed splits in a dataframe
#'
#' Allows the return of speed splits of multiple rides.
#'
#' @author Marcus Beck
#' 
#' @concept token
#' 
#' @param act_id a vector of activity IDs. These are easily found in the \code{data.frame} returned by \code{\link{compile_activities}}
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' @param units chr string indicating plot units as either metric or imperial
#' @return a data frame containing the splits of the activity or activities selected.
#' 
#' @import magrittr
#' 
#' @examples 
#' \dontrun{
#' # get my activities
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, app_secret, cache = TRUE))
#' my_acts <- get_activity_list(stoken)
#' 
#' # compile activities
#' acts_data <- compile_activities(my_acts)
#' 
#' # get spdsplits for all activities
#' spd_splits <- purrr::map_df(acts_data$id, get_spdsplits, stoken = stoken, units = 'metric', .id = 'id')
#' }
#' @export get_spdsplits

get_spdsplits <- function(act_id, stoken, units = 'metric'){
	
	# get the activity, split speeds are not in the actframe
	act <- rStrava::get_activity(act_id, stoken)
	
	# split type
	sptyp <- paste0('splits_', units)
	sptyp <- gsub('imperial$', 'standard', sptyp)
	
	# get speed per split,  convert from m/s to km/hr
	splt <- lapply(act[[sptyp]], function(x) x[['average_speed']]) %>% 
		do.call('rbind', .) %>% 
		data.frame(spd = ., split = 1:length(.))
	splt$spd <- 3.6 * splt$spd
	splt2 <- lapply(act[[sptyp]], function(x) x[['elapsed_time']]) %>% 
		do.call('rbind', .) %>% 
		data.frame(elapsed_time = .)
	if(units == 'imperial'){
		# m/s to mph
		splt$spd <- splt$spd * 0.621371
	}
	return(cbind(splt, splt2))
}
