#' Remove activities with no geographic data
#' 
#' Remove activities with no geographic data, usually manual entries
#' 
#' @author Marcus Beck
#' 
#' @concept token
#' 
#' @param act_data a \code{data.frame} returned by \code{\link{compile_activities}}
#' @param ... arguments passed to or from other methods
#' 
#' @details This function is used internally within \code{\link{get_elev_prof}} and \code{\link{get_heat_map}} to remove activities that cannot be plotted because they have no geographic information.  This usually applies to activities that were manually entered.
#' 
#' @return \code{act_data} with rows removed where no polylines were available, the original dataseset is returned if none were found. A warning is also returned indicating the row numbers that were removed if applicable. 
#' 
#' @examples
#' \dontrun{
#' # get my activities
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, app_secret, cache = TRUE))
#' my_acts <- get_activity_list(stoken)
#' act_data <- compile_activities(my_acts)
#' chk_nopolyline(act_data)
#' }
#' @export
chk_nopolyline <- function(act_data, ...) UseMethod('chk_nopolyline')

#' @rdname chk_nopolyline
#'
#' @export
#'
#' @method chk_nopolyline actframe
chk_nopolyline.actframe <- function(act_data, ...){
	
	# remove manual entries without polylines
	if('map.summary_polyline' %in% names(act_data))
		nolines <- which(is.na(act_data$map.summary_polyline))
	if('map.polyline' %in% names(act_data))
		nolines <- which(is.na(act_data$map.polyline))
	
	if(any(nolines)){
		
		act_data <- act_data[-nolines, ]
		
		if(nrow(act_data) == 0)
			stop("No activities with geographic information")

		warning("Activities with no geographic information were removed, rows ", paste(nolines, collapse = ', '))	
		
	}
	
	return(act_data)
	
}
