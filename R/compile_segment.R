#' Compile information on a segment
#' 
#' Compile generation information on a segment
#' 
#' @param segment_id a Strava segment id
#' @param stoken A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function
#' 
#' @concept token
#' @details compiles information a segment by calling \code{\link{get_segment}} internally
#' @return dataframe of all information given in a call from \code{\link{get_segment}}
#' @export
compile_segment <- function(segment_id, stoken){

	temp <- rStrava::get_segment(stoken, id = segment_id)
	temp <- data.frame(unlist(temp), stringsAsFactors = F)
	temp$ColNames <- rownames(temp)
	temp <- tidyr::spread(temp, ColNames, unlist.temp.)
	return(temp)
}
