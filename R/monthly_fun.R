#' Get distances for last twelve months
#'
#' Get distances for last twelve months, used internally in \code{\link{athl_fun}}
#' 
#' @param prsd parsed \code{\link[XML]{htmlTreeParse}} list
#'
#' @import XML
#' 
#' @export
#' 
#' @concept notoken
monthly_fun <- function(prsd){
	
	# to eval
	unts <- prsd[['units']]
	prsd <- prsd[['parsed']]
	
	# text to remove from parsed data
	to_rm <- paste(unts, collapse = '|')
	to_rm <- paste0(to_rm, '|\\n|\\DISTANCE')
	
	# monthly total for most recent month
	mos_sum <- xpathSApply(prsd, "//ul[@class='inline-stats']//li", xmlValue)
	
	# names of months
	mos_nms <- xpathSApply(prsd, "//div[@class='x-axis']//div[@class='label']", 
												 xmlValue)
	mos_nms <- gsub('\\n', '', mos_nms)
	
	# scl value since bar graph is 0-100, this is monthly total for last month
	scl_val <- mos_sum[grep('DISTANCE',mos_sum)]
	scl_val <- as.numeric(gsub(to_rm, '', scl_val))
	
	# proportion of miles from bar graph
	mos_val <- xpathSApply(prsd, "//div[@class='fill']")
	mos_val <- sapply(mos_val, function(x) xmlAttrs(x)['style'])
	mos_val <- as.numeric(gsub('height: |px;', '', mos_val))
	
	# return all zeroes if no activity in last twelve months
	if(length(mos_val) == 0){
		
		mos_val <- rep(0, length = length(mos_nms))
		names(mos_val) <- mos_nms
		
		return(mos_val)
		
	}
	
	# used to extend mos_val to length of bar chart if not full
	mos_ind <- xpathSApply(prsd, "//div[@class='bar']", xmlValue)
	mos_ind <- grepl('\\n\\n', mos_ind)
	mos_ful <- rep(0, length(mos_ind))
	mos_ful[mos_ind] <- mos_val
	mos_val <- mos_ful
	
	# make scl_val a proportion, based on last value in bar chart that is not zero
	scl_val <- scl_val/(rev(mos_val[mos_val != 0])[1])
	
	# get proper values for mos_val
	mos_val <- mos_val * scl_val
	
	# output
	names(mos_val) <- mos_nms
	
	return(mos_val)
	
}
