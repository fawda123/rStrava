#' Get summary data for an athlete
#'
#' Get summary data for an athlete, year to date and total units of measurement. Used internally in \code{\link{athl_fun}}.
#' 
#' @param prsd parsed \code{\link[XML]{htmlTreeParse}} list
#'
#' @import plyr XML
#' 
#' @concept notoken
#' 
#' @return two-element list
summ_fun <- function(prsd){

	# to eval
	unts <- prsd[['units']]
	prsd <- prsd[['parsed']]
	
	# text to remove from parsed data
	to_rm <- paste(unts, collapse = '|')
	to_rm <- paste0(to_rm, '|,')
	
	# class of table (cylcing, running, etc.), not used  
	tab_cls <- xpathSApply(prsd, '//table//tr//th//strong', xmlValue)
	
	# summary data
	sum_lab <- xpathSApply(prsd, '//table//tbody//tr//th', xmlValue)
	sum_val <- xpathSApply(prsd, '//table//tbody//tr//td', xmlValue)
	
	# add names, remove unti labels
	names(sum_val) <- sum_lab
	sum_val <- gsub(to_rm, '', sum_val)
	
	# format time as decimal hours
	tim_dat <- sum_val[grep('Time', names(sum_val))]
	tim_dat <- laply(tim_dat,
									 .fun = function(x) {
									 	
									 	vals <- as.numeric(strsplit(x, ' ')[[1]])
									 	vals[2] <- vals[2]/60
									 	vals[1] + vals[2]
									 	
									 })
	sum_val[grep('Time', names(sum_val))] <- tim_dat 
	
	# format and return results
	sum_val <- as.numeric(sum_val)
	names(sum_val) <- sum_lab
	out <- list(
		year_to_date = sum_val[!grepl('Total', names(sum_val))],
		all_time = sum_val[grepl('Total', names(sum_val))]
	)
	
	return(out)
	
}