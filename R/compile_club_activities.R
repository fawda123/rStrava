#' converts a list of club activities into a dataframe
#' 
#' converts a list of club activities into a dataframe
#' 
#' @param actlist a club activities list returned by \code{\link{get_activity_list}}
#' 
#' @author Marcus Beck
#' 
#' @return An \code{data.frame} of the compiled activities from \code{actlist}
#' 
#' @details each activity has a value for every column present across all activities, with NAs populating empty values
#'
#' @concept token
#' 
#' @export
#' 
#' @examples  
#' \dontrun{
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, app_secret, cache = TRUE))
#' 
#' club_acts <- get_activity_list(stoken, id = 13502, club = TRUE)
#' 
#' acts_data <- compile_club_activities(club_acts)
#' 
#' }
compile_club_activities <- function(actlist){

	out <- tibble::enframe(actlist) %>% 
		dplyr::mutate(value = purrr::map(value, compile_activity)) %>% 
		tidyr::unnest(cols = c(value)) %>% 
		dplyr::mutate_at(dplyr::vars(dplyr::matches('^distance$|^elapsed\\_time$|^moving\\_time$|^total\\_elevation\\_gain$')), dplyr::funs(as.numeric(.))) %>% 
		dplyr::rename(activity = name) %>% 
		as.data.frame(stringsAsFactors = FALSE)
		
	return(out)
	
}
