#' Get several pages of one type of request
#' 
#' Get several pages of one type of request to the API
#' 
#' @param url_ string of url for the request to the API
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' @param per_page numeric indicating number of items retrieved per page (maximum 200)
#' @param page_id numeric indicating page id
#' @param page_max numeric indicating maximum number of pages to return
#' @param before date object for filtering activities before the indicated date
#' @param after date object for filtering activities after the indicated date
#' @param queries list of additional queries to pass to the API
#' @param All logical if you want all possible pages
#'
#' @details Requires authentication stoken using the \code{\link{strava_oauth}} function and a user-created API on the strava website.   
#' 
#' @return Data from an API request.
#' 
#' @concept token
#' 
#' @import httr
#' 
#' @export
#' 
#' @examples
#' \dontrun{
#' # create authentication token
#' # requires user created app name, id, and secret from Strava website
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, 
#' 	app_secret, cache = TRUE))
#' 
#' # get basic user info
#' # returns 30 activities
#' get_pages('https://www.strava.com/api/v3/activities', stoken)
#' 
#' }
get_pages <- function(url_, stoken, per_page = 30, page_id = 1, page_max = 1, before = NULL, after = NULL, queries = NULL, All = FALSE) {

    dataRaw <- list()

    # check for leaderboard request
    # per_page and length of content request are handled differently
    chk_lead <- grepl('leaderboard$', url_)
    
    # Process date filters once at the beginning
    before <- seltime_fun(before, TRUE)
    after <- seltime_fun(after, FALSE)
    
    # Set parameters for All pages request
    if (All) {
        per_page <- 200  # reduces the number of requests
        page_id <- 1
        page_max <- Inf  # No limit on pages when All = TRUE
    }
    
    # Store original per_page for consistent API requests
    api_per_page <- per_page
    
    i <- page_id - 1
    repeat {
        i <- i + 1

        if (chk_lead) {
            # For leaderboard, respect 200 item API limit
            current_per_page <- pmin(200, api_per_page)
            req <- GET(url_, stoken, query = c(list(per_page = current_per_page, page = i), queries))
            
        } else {
            # For regular requests, include date filters
            req <- GET(url_, stoken, query = c(list(per_page = api_per_page, page = i, before = before, after = after), queries))
        }
        
        # Check for HTTP errors
        stop_for_status(req)
        
        # Parse response
        cont_req <- content(req, as = 'text', encoding = 'UTF-8')
        cont_req <- jsonlite::fromJSON(cont_req, simplifyVector = FALSE, bigint_as_char = TRUE)
        
        # Handle leaderboard vs regular response structure
        if (chk_lead) {
            cont_req <- cont_req$entries
        }
        
        # Add data to results
        dataRaw <- c(dataRaw, cont_req)

        # Break conditions
        if (length(cont_req) < api_per_page) {
            # Last page - got fewer items than requested
            break
        }
        if (i >= page_max) {
            # Reached maximum pages
            break
        }
        if (length(cont_req) == 0) {
            # No data returned
            break
        }
    }
    
    return(dataRaw)
}