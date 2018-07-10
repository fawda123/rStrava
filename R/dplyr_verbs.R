#' Filter
#'
#' This is a wrapper function to dplyr::filter which can be applied to an actframe object
#'
#' @param .data an actframe object
#' @param ... Logical predicates defined in terms of the variables in .data
#'
#' @importFrom dplyr filter
#'
#' @return an actframe object

#'
#' @examples
#' \dontrun{
#' 
#' # get actframe, all activities
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, app_secret, cache = TRUE))
#' my_acts <- get_activity_list(stoken)
#' act_data <- compile_activities(my_acts)
#' 
#' # mutate
#' act_data %>% filter(name %in% 'Morning Ride')
#' }
filter.actframe <- function(.data,...) {
	
	# capture classes
	old_classes <- class(.data)
	
	# capture attributes
	unit_type <- attr(.data,'unit_type')
	unit_vals <- attr(.data,'unit_vals')
	
	# strip actframe class
	class(.data) <- old_classes[!old_classes == 'actframe']
	
	# perform operation
	.data <- .data %>% dplyr::filter(...)
	
	# add back actframe class
	class(.data) <- c('actframe',class(.data))
	attr(.data,'unit_type') <- unit_type
	attr(.data,'unit_vals') <- unit_vals
	
	return(.data)
}

#' Mutate
#'
#' This is a wrapper function to dplyr::mutate which can be applied to an actframe object
#'
#' @param .data an actframe object
#' @param ... Name-value pairs of expressions. Use NULL to drop a variable.
#'
#' @importFrom dplyr mutate
#'
#' @return an actframe object

#'
#' @examples
#' \dontrun{
#' 
#' # get actframe, all activities
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, app_secret, cache = TRUE))
#' my_acts <- get_activity_list(stoken)
#' act_data <- compile_activities(my_acts)
#' 
#' # mutate
#' act_data %>% mutate(is_run=type=='Run')
#' }
mutate.actframe <- function(.data,...) {
	
	# capture classes
	old_classes <- class(.data)
	
	# capture attributes
	unit_type <- attr(.data,'unit_type')
	unit_vals <- attr(.data,'unit_vals')
	
	# strip actframe class
	class(.data) <- old_classes[!old_classes == 'actframe']
	
	# perform operation
	.data <- dplyr::mutate(.data,...)
	
	# add back actframe class
	class(.data) <- c('actframe',class(.data))
	attr(.data,'unit_type') <- unit_type
	attr(.data,'unit_vals') <- unit_vals
	
	return(.data)
}