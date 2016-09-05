#' converts a list of activities into a dataframe
#' 
#' converts a list of activities into a dataframe
#' 
#' @param list a list of all the activities you want compiling. Generally produced by \code{\link{compile_activity}}
#' @author Daniel Padfield
#' @return dataframe where each row is a different activity
#' @details each activity has a value for every column present across all activities, with NAs populating empty values
#' @concept posttoken
#' @export

compile_activities <- function(list){
	temp <- unlist(list)
	att <- unique(attributes(temp)$names)
	return(plyr::ldply(list, activity_compiler, columns = att))
}
