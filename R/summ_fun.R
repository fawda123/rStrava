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
	
	# class of table (cycling, running, etc.), not used  
	tab_cls <- xpathSApply(prsd, '//table//tr//th//strong', xmlValue)

	# get current month info, distance, time and elevation
	cmo <- xpathSApply(prsd, '//ul', xmlValue)
	cmo <- grep('DISTANCE|TIME|ELEVATION', cmo, value = TRUE)
	cmo <- strsplit(cmo, '\\n')[[1]]
	cmo <- grep('[0-9]+', cmo, value = TRUE)
	cmo_tim <- grep('[[:space:]]', cmo, value = TRUE)
	cmo_tim <- as.numeric(strsplit(gsub('[a-z]*', '', cmo_tim), ' ')[[1]])
	cmo_tim <- cmo_tim[1] + cmo_tim[2]/60
	cmo[2] <- cmo_tim
	cmo <- as.numeric(gsub('[a-z]*', '', cmo))
	names(cmo) <- c('Distance', 'Time', 'Elevation')
	
	# summary data
	sum_lab <- xpathSApply(prsd, '//table//tbody//tr//th', xmlValue)
	sum_val <- xpathSApply(prsd, '//table//tbody//tr//td', xmlValue)
	
	# add names, remove unit labels
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
		current_month = cmo,
		year_to_date = sum_val[!grepl('Total', names(sum_val))],
		all_time = sum_val[grepl('Total', names(sum_val))]
	)
	
	return(out)
	
}