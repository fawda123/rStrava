#' Plot speed by splits
#'
#' Plot average speed by splits for a single activity
#'
#' @author Marcus Beck
#' 
#' @concept token
#' 
#' @param act_data an activities list object returned by \code{\link{get_activity_list}} or a \code{data.frame} returned by \code{\link{compile_activities}}
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' @param acts numeric indicating which activity to plot based on index in the activities list, defaults to most recent
#' @param units chr string indicating plot units as either metric or imperial
#' @param fill chr string of fill color for profile
#' @param ... arguments passed to other methods
#' 
#' @details The average speed per split is plotted, including a dashed line for the overall average.  The final split is typically not a complete km or mile.  
#' 
#' @return plot of average distance for each split value in the activity
#' 
#' @export
#' 
#' @import magrittr
#' 
#' @examples 
#' \dontrun{
#' # get my activities
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, app_secret, cache = TRUE))
#' my_acts <- get_activity_list(stoken)
#' 
#' # default
#' plot_spdsplits(my_acts, stoken, acts = 1)
#' }
plot_spdsplits <- function(act_data, ...) UseMethod('plot_spdsplits')

#' @rdname plot_spdsplits
#'
#' @export
#'
#' @method plot_spdsplits list
plot_spdsplits.list <- function(act_data, stoken, acts = 1, units = 'metric', fill = 'darkblue', ...){
	
	# compile
	act_data <- compile_activities(act_data, acts = acts, units = units)

	plot_spdsplits.default(act_data, stoken, size = size, units = units, fill = fill, ...)	
	
}

#' @rdname plot_spdsplits
#'
#' @export
#'
#' @method plot_spdsplits default
plot_spdsplits.default <- function(act_data, stoken, units = 'metric', fill = 'darkblue', ...){
	
	# get the activity, split speeds are not in the actframe
	act <- get_activity(act_data$id[1], stoken)
	
	# split type
	sptyp <- paste0('splits_', units)
	sptyp <- gsub('imperial$', 'standard', sptyp)
	
	# get speed per split,  convert from m/s to km/hr
	splt <- lapply(act[[sptyp]], function(x) x[['average_speed']]) %>% 
		do.call('rbind', .) %>% 
		data.frame(spd = ., split = 1:length(.))
	splt$spd <- 3.6 * splt$spd 
	ave <- 3.6 * act$average_speed
	
	# ylabel
	ylab <- 'Average Speed (km/hr)'
	xlab <- 'Split (km)'
	if(units == 'imperial'){
		
		# m/s to mph
		splt$spd <- splt$spd * 0.621371
		ave <- 0.621371 * ave
		
		ylab <- gsub('km', 'mi', ylab)
		xlab <- gsub('km', 'mi', xlab)
		
	}
	
	p <- ggplot2::ggplot(splt, ggplot2::aes(x = factor(split), y = spd)) + 
		ggplot2::geom_bar(stat = 'identity', fill = fill) + 
		ggplot2::theme_bw() +
		# ggplot2::theme(
		# 	panel.grid.major = ggplot2::element_blank(),
		# 	panel.grid.minor = ggplot2::element_blank()
		# ) +
		ggplot2::scale_x_discrete(xlab) +
		ggplot2::scale_y_continuous(ylab) +
		ggplot2::geom_hline(ggplot2::aes(yintercept = ave), linetype = 'dashed')
	
	return(p)
	
}
