compile_seg_effort <- function(x){
	temp <- data.frame(unlist(x)) %>%
		mutate(ColNames = rownames(.)) %>%
		spread(., ColNames, unlist.x.)
	desired_cols <- c('athlete.id', 'distance', 'elapsed_time', 'moving_time', 'name', 'start_date', 'start_date_local')
	# check which columns arent present
	cols_not_present <- desired_cols[! desired_cols %in% colnames(temp)] %>%
		data.frame(cols = .) %>%
		mutate(., value = NA)
	if(nrow(cols_not_present) >= 1){cols_not_present <- spread(cols_not_present, cols, value)}
	if(nrow(cols_not_present) == 1){temp <- cbind(temp, cols_not_present)}
	temp <- select(temp, athlete.id, distance, elapsed_time, moving_time, name, start_date, start_date_local)
	return(temp)
}
