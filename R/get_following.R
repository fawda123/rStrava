#' Get followers, friends, or both-following
#' 
#' Get followers or friends of the athlete or both-following relative to another user
#' 
#' @param following string equal to `friends', `followers', or `both-following'
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' @param id string or integer of athlete, taken from \code{stoken} if \code{NULL}
#' @param All logical for retrieving all the friends or followers when they are more than 200.
#' @param ... optional arguments to the \code{\link{get_pages}} function.
#'
#' @details Requires authentication stoken using the \code{\link{strava_oauth}} function and a user-created API on the strava website.\n The default values will return the first page with up to 200 profiles. Use \code{All = TRUE} for retrieving all the profiles when having more than 200 friends or followers. You can pass other arguments to the \code{\link{get_pages}} function to have a better control of the amount of users to download
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
#' get_following('friends', stoken)
#' 
#' # retrieve up to 1000 followers
#' get_following('followers', stoken, page_max=5)
#' 
#' # retrieve all the friends. Be carefull with the API rate limits
#' get_following('friends', stoken, All = TRUE)
#' }

get_following <- function(following, stoken, id = NULL, per_page = 200, page_id = 1, page_max = 1, All = FALSE){
  
  url_ <- paste(url_athlete(id),"/", following, sep = "")
  dataRaw <- get_pages(url_, stoken,
                       per_page = per_page, page_id = page_id, page_max = page_max,
                       All = All)
  return(dataRaw)

}

