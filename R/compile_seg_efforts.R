compile_seg_efforts <- function(x, stoken){
	temp1 <- get_efforts_list(stoken, id = x)
	temp2 <- suppressWarnings(purrr::map_df(temp1, compile_effort))
	return(temp2)
}