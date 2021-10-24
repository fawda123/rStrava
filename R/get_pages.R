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
#' get_pages('https://strava.com/api/v3/activities', stoken)
#' 
#' }
get_pages<-function(url_, stoken, per_page = 30, page_id = 1, page_max = 1, before=NULL, after=NULL, queries=NULL, All = FALSE){

	dataRaw <- list()

	# check for leaderboard request
	# per_page and length of content request are handled differently
	chk_lead <- grepl('leaderboard$', url_)
	
	# initalize usage_left with ratelimit
	req <- GET(url_, stoken, query = c(list(per_page=per_page, page=page_id), queries))
	usage_left <- ratelimit(req)

	before <- seltime_fun(before, TRUE)
	after <- seltime_fun(after, FALSE)
	
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

		if(chk_lead){
			
			req <- GET(url_, stoken, query = c(list(per_page=pmin(200, per_page), page=i), queries))
			cont_req <- content(req)$entries
			
			if(length(cont_req) == 200){
				per_page <- per_page - length(cont_req)
				page_max <- 1 + page_max
			}
			
			if(per_page == 0) page_max <- i
				
		} else {
			
			req <- GET(url_, stoken, query = c(list(per_page=per_page, page=i, before=before, after=after), queries))
			cont_req <- content(req)
			
		}
	
		ratelimit(req)
		stop_for_status(req)
		dataRaw <- c(dataRaw, cont_req)

		if(length(cont_req) < per_page) {#breaks when the last page retrieved less items than the per_page value
			break
		}
		if(i>=page_max) {#breaks when the max number of pages or ratelimit was reached
			break
		}
	}
	return(dataRaw)
}
