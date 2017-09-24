compile_segment <- function(x, columns, stoken){
	temp <- rStrava::get_segment(stoken, id = x)
	temp <- data.frame(unlist(temp), stringsAsFactors = F)
	temp$ColNames <- rownames(temp)
	temp <- tidyr::spread(temp, ColNames, unlist.temp.)
	return(temp)
}
