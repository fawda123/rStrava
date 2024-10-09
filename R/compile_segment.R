#' Compile information on a segment
#' 
#' Compile generation information on a segment
#' 
#' @param seglist a Strava segment list returned by \code{\link{get_segment}}
#' 
#' @concept token
#' @details compiles information for a segment
#' @return dataframe of all information given in a call from \code{\link{get_segment}}
#' @export
#' 
#' @examples 
#' \dontrun{
#' # create authentication token
#' # requires user created app name, id, and secret from Strava website
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, 
#' 	app_secret, cache = TRUE))
#' 
#' # compile segment info
#' get_segment(stoken, id = '229781') %>% compile_segment
#' 
#' # compile top ten leaderboard for the segment
#' get_segment(stoken, id = '229781', request = "leaderboard") %>% compile_segment
#' 
#' # compile all efforts for the authenticated user on the segment
#' get_segment(stoken, id = '4483903', request = 'all_efforts') %>% compile_segment
#'
#' # compile the starred segments for the user
#' get_segment(stoken, request = 'starred') %>% compile_segment
#' }
compile_segment <- function(seglist){

	if('entries' %in% names(seglist)){

		# leaderboard
		out <- tibble::enframe(seglist$entries) %>%
			dplyr::mutate(value = purrr::map(value, function(x) as.data.frame(x, stringsAsFactors = FALSE))) %>%
			tidyr::unnest() %>%
			dplyr::select(-name) %>%
			as.data.frame(stringsAsFactors = FALSE)

	} else {
		
		if(is.null(names(seglist))){
			
			# starred or efforts
			out <- tibble::enframe(seglist) %>% 
				dplyr::mutate(value = purrr::map(value, function(x) x %>% unlist %>% tibble::enframe(.) %>% tidyr::unnest(.) %>% tidyr::spread('name', 'value')))
			out <- dplyr::bind_rows(out$value)
			
		} else {
			
			# segment info
			out <- data.frame(unlist(seglist), stringsAsFactors = F)	
			out$ColNames <- rownames(out)			
			out <- tidyr::spread(out, ColNames, unlist.seglist.)
			
		}
	}
	
	return(out)
	
}
