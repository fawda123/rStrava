#' Retrieve details about a specific segment
#' 
#' Retreive details about a specific segment
#'
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' @param id numeric for id of the segment
#' @param request chr string, must be "starred", "leaderboard", "all_efforts", or NULL for segment details
#' 
#' @details Requires authentication stoken using the \code{\link{strava_oauth}} function and a user-created API on the strava website.  The authenticated user must have an entry for a segment to return all efforts if \code{request = "all_efforts"}. For \code{request = "starred"}, set \code{id = NULL}.
#' 
#' @return Data from an API request.
#' 
#' @export 
#' 
#' @concept token
#' 
#' @import httr
#' 
#' @seealso \code{\link{compile_segment}} for converting the \code{list} output to \code{data.frame}
#' @examples
#' \dontrun{
#' # create authentication token
#' # requires user created app name, id, and secret from Strava website
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, 
#' 	app_secret, cache = TRUE))
#' 
#' # get segment details
#' get_segment(stoken, id = 229781)
#' 
#' # get leaderboard
#' get_segment(stoken, id = 229781, request = 'leaderboard')
#' 
#' # get starred segments for the authenticated user
#' get_segment(stoken, request = 'starred')
#' }
get_segment <- function(stoken, id = NULL, request = NULL){

	if(!is.null(id) & request == 'starred')
		stop('id must be NULL if request = "starred"')
	
	dataRaw <- get_basic(url_segment(id, request = request), stoken)
	return(dataRaw)
	
}
