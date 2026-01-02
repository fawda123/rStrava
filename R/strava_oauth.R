#' Generata Strava API authentication token
#' 
#' Generate a token for the user and the desired scope. The user is sent to the strava authentication page if he/she hasn't given permission to the app yet, else, is sent to the app webpage.
#'
#' @param app_name chr string for name of the app
#' @param app_client_id chr string for ID received when the app was registered
#' @param app_secret chr string for secret received when the app was registered
#' @param app_scope chr string for scope of authentication, Must be one of "public", "read" , "read_all", "profile:read_all", "profile:write", "activity:read", "activity:read_all" or "activity:write"
#' @param cache logical to cache the token, default is set
#'
#' @details The \code{app_name}, \code{app_client_id}, and \code{app_secret} are specific to the user and can be obtained by registering an app on the Strava API authentication page: \url{http://strava.github.io/api/v3/oauth/}.  This requires a personal Strava account.
#'
#' @import httr
#' 
#' @export
#'
#' @concept token
#' 
#' @return A \code{Token2.0} object returned by \code{\link[httr]{oauth2.0_token}} to be used with API function calls
#' 
#' @examples 
#' \dontrun{
#' app_name <- 'myappname' # chosen by user
#' app_client_id  <- 'myid' # an integer, assigned by Strava
#' app_secret <- 'xxxxxxxx' # an alphanumeric secret, assigned by Strava
#'
#' # create the authentication token
#' stoken <- httr::config(
#'   token = strava_oauth(
#'     app_name, 
#'     app_client_id, 
#'     app_secret, 
#'     app_scope="activity:read_all"
#'   )
#' )
#'
#' # use authentication token
#' get_athlete(stoken, id = '2837007')
#' }
strava_oauth <- function(app_name, app_client_id, app_secret,
                         app_scope = c("public", "read" , "read_all", "profile:read_all", "profile:write", "activity:read", "activity:read_all", "activity:write"),
                         cache = TRUE){

        app_scope <- match.arg(app_scope)

	strava_app <- oauth_app(appname = app_name, key = app_client_id, secret = app_secret)  
	
	strava_end <- oauth_endpoint(
		request = "https://www.strava.com/oauth/authorize?",
		authorize = "https://www.strava.com/oauth/authorize",
		access = "https://www.strava.com/oauth/token")
	
	oauth2.0_token(endpoint = strava_end, 
								 app = strava_app, 
								 scope = app_scope, 
								 cache = cache)
	
}
