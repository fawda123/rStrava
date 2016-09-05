#' convert a single activity list into a dataframe
#' 
#' convert a single activity list into a dataframe
#' @author Daniel Padfield
#' @details used internally in \code{\link{get_activities_dataframe}}
#' @param x a list containing details of a single Strava activity
#' @param columns a character vector of all the columns in the list of Strava activities. Produced automatically in \code{\link{get_activities_dataframe}}. Leave blank if running for a single activity list.
#' @return dataframe where every column is an item from a list. Any missing columns rom the total number of columns 
#' @concept posttoken
#' @export

activity_compiler <- function(x, columns){
	library(magrittr)
	library(dplyr)

	temp <- data.frame(unlist(x), stringsAsFactors = F) %>%
		mutate(ColNames = rownames(.)) %>%
		spread(., ColNames, unlist.x.)
	if(missing(columns)){return(temp)}
	else{
	cols_not_present <- columns[! columns %in% colnames(temp)] %>%
		data.frame(cols = .) %>%
		mutate(., value = NA)
	if(nrow(cols_not_present) >= 1){cols_not_present <- tidyr::spread(cols_not_present, cols, value)}
	if(nrow(cols_not_present) == 1){temp <- cbind(temp, cols_not_present)}
	return(temp)}
}
