#' Get several pages of one type of request
#' 
#' Get several pages of one type of request to the API
#' 
#' @param url_ string of url for the request to the API
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' @param per_page numeric indicating number of items retrieved per page (maximum 200)
#' @param page_id numeric indicating page id
#' @param page_max numeric indicating maximum number of pages to return
#' @param queries list of additional queries to pass to the API
#' @param All logical if you want all possible pages within the ratelimit constraint
#'
#' @details Requires authentication stoken using the \code{\link{strava_oauth}} function and a user-created API on the strava website.   
#' 
#' @return Data from an API request.
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
#' # get basic user info
#' # returns 30 activities
#' get_pages('https://strava.com/api/v3/activities', stoken)
#' 
#' }
get_pages<-function(url_, stoken, per_page = 30, page_id = 1, page_max = 1, queries=NULL, All = FALSE){

	dataRaw <- list()
	
	if(All){
		per_page=200 #reduces the number of requests
		page_id=1
		page_max=usage_left[1]
	}
	else if(page_max > usage_left[1]){#Trying to avoid exceeding the 15 min limit
		page_max <- usage_left[1]
		print (paste("The number of pages would exceed the rate limit, retrieving only"), usage_left[1], "pages")
	}      
	
	i = page_id - 1
	repeat{
		i <- i + 1
		req <- GET(url_, stoken, query = c(list(per_page=per_page, page=i), queries))
		ratelimit(req)
		stop_for_status(req)
		dataRaw <- c(dataRaw,content(req))
		if(length(content(req)) < per_page) {#breaks when the last page retrieved less items than the per_page value
			break
		}
		if(i>=page_max) {#breaks when the max number of pages or ratelimit was reached
			break
		}
	}
	return(dataRaw)
}
