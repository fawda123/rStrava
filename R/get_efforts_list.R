#' Get all the efforts in a segment if no queries are specified
#' 
#' Get all the efforts in a segment if no queries are specified
#'
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' @param id character string for id of the segment
#' @param athlete_id character string for the athlete id for filtering the results
#' @param start_date_local the start date for filtering the results 
#' @param end_date_local the end date for filtering the results
#' 
#' @details Requires authentication stoken using the \code{\link{strava_oauth}} function and a user-created API on the strava website.
#' 
#' @return Data from an API request.
#' 
#' @export
#' 
#' @concept token
#' 
#' @import httr
#' 
#' @examples
#' \dontrun{
#' # create authentication token
#' # requires user created app name, id, and secret from Strava website
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, 
#' 	app_secret, cache = TRUE))
#' 
#' get_efforts_list(stoken, id = '229781')
#' }
get_efforts_list <- function(stoken, id, athlete_id=NULL, start_date_local=NULL, end_date_local=NULL){

	if(any(!is.character(id))) 
		stop('id must be a character vector')
	
	queries <- list(athlete_id=athlete_id,
									start_date_local=start_date_local,
									end_date_local=end_date_local)
	
	dataRaw <- get_pages(url_segment(id, request="all_efforts"), stoken, queries=queries, All=TRUE)
	return(dataRaw)

}