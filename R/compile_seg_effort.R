#' Compile the efforts of a segment
#' 
#' Cleans up the output of get_efforts_list() into a dataframe
#' 
#' @param x A list object produced by \code{\link{get_efforts_list}}
#' 
#' @author Daniel Padfield
#'
#' @details Used internally in \code{\link{compile_seg_efforts}}. Can be used on the output of \code{\link{get_efforts_list}} to compile the segment efforts of a single segment. Each call to \code{\link{get_efforts_list}} returns a large list. This function returns a subset of this information.
#' 
#' @concept notoken
#' 
#' @return A dataframe containing all of the efforts of a specific segment. The columns returned are \code{athlete.id}, \code{distance}, \code{elapsed_time}, \code{moving_time}, \code{name}, \code{start_date} and \code{start_date_local}.
#' 
#' @examples
#' \dontrun{
#' # set token
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, app_secret, cache = TRUE))
#' 
#' # segments to get efforts from - use some parkruns
#' segment <- 2269028
#' 
#' # get segment efforts
#' efforts <- get_efforts_list(stoken, segment)
#' 
#' # compile efforts
#' efforts <- compile_seg_effort(efforts)
#' }
#' @export
compile_seg_effort <- function(x){

	# categories to get from each effort
	desired_cols <- c('athlete.id', 'distance', 'elapsed_time', 'moving_time', 'name', 'start_date', 'start_date_local') %>% 
		data.frame(ColNames = ., stringsAsFactors = F)
	
	# compile efforts
	temp <- x %>% 
		purrr::map(function(x){
			
			out <- data.frame(unlist(x)) %>%
				dplyr::mutate(ColNames = rownames(.)) %>% 
				left_join(desired_cols, ., by = 'ColNames') %>% 
				spread(ColNames, unlist.x.)
			
		}) %>% 
		do.call('rbind', .)

	return(temp)
	
}
