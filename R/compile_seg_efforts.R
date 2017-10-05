#' Compile the efforts of multiple segments
#' 
#' Compiles the information of athletes from multiple segments
#' 
#' @param segment_ids A vector of segment ids from which to compile efforts
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' 
#' @author Daniel Padfield
#'
#' @details Uses \code{\link{get_elev_prof}} and \code{\link{compile_seg_effort}} internally to compile efforts of multiple segments
#' 
#' @concept token
#' 
#' @return A dataframe of the details of each segment effort
#' 
#' @examples
#' \dontrun{
#' # set token
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, app_secret, cache = TRUE))
#' 
#' # segments to get efforts from - use some parkruns
#' segments <- c(2269028, 5954625)
#' 
#' # compile segment efforts
#' segments %>% purrr::map_df(., .f = compile_segment_efforts, stoken = my_token, .id = 'id')
#' }
#' @export

compile_seg_efforts <- function(segment_ids, stoken){
	
	temp1 <- rStrava::get_efforts_list(stoken, id = segment_ids)
	
	temp2 <- suppressWarnings(purrr::map_df(temp1, rStrava::compile_seg_effort))
	
	return(temp2)
}