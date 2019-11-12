#' Convert a set of streams of a single activity into a dataframe
#' 
#' Convert a set of streams of a single activity into a dataframe, with the retrieved columns.
#' @author Lorenzo Gaborini
#' @details used internally in \code{\link{get_activity_streams}}
#' @param streams a list containing details of the Strava streams of a single activity (output of \code{\link{get_streams}})
#' @param id if not missing, the activity id of the stream (will be appended to the data.frame, if non-empty)
#' @return data frame where every column is the stream data for the retrieved types.
#' @concept token
#' @importFrom magrittr %>%
#' @examples 
#' \dontrun{
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, app_secret, cache = TRUE))
#' 
#' act_id <- 351217692
#' streams <- get_streams(stoken, id = act_id, types = list('distance', 'latlng'))
#' 
#' compile_activity_streams(streams, id = act_id)}
compile_activity_streams <- function(streams, id = NULL){

   if (!is.null(id) && length(id) != 1) {
      stop('id must be a scalar or NULL.')
   }
   
   # Remove 'resolution', 'series_type', 'original_size' columns from stream contents
   tmp <- streams %>% 
      purrr::transpose(.) %>% 
      tibble::as.tibble() %>% 
      dplyr::select(type, data) %>% 
      dplyr::mutate(
      	type = unlist(type), 
      	data = purrr::map(data, function(x){
      			
      		# replace numeric(0) values with NA
      		idx <- !sapply(x, length)
      		x[idx] <- NA
      		
      		return(x)
      		
      	})
      )
   
   # Expand data column to columns removing one layer of lists
   tmp.wide <- tmp %>% 
      tidyr::spread(data = ., key = type, value = data) %>% 
      tidyr::unnest(cols = c(altitude, distance, grade_smooth, latlng, moving, time, velocity_smooth))
   
   # Or:
   # tmp.wide <- x %>% map_dfc(~ tibble(data = pluck(.x, 'data')) %>% set_names(pluck(.x, 'type')))

   # Deal with latitude-longitude field separately
   if ('latlng' %in% colnames(tmp.wide)) {
      
      # Remove singletons (list-columns with 1-long lists)
      df.wide <- tmp.wide %>% 
         tidyr::unnest(cols = c(altitude, distance, grade_smooth, moving, time, velocity_smooth))
      
      # Assign names to latlng field
      f.latlng.to.df <- function(x) {
         purrr::set_names(x, nm = c('lat', 'lng')) %>% 
            tibble::as.tibble()
      }
      
      # and unnest to columns
      df.stream <- df.wide %>% 
         dplyr::mutate(latlng = purrr::map(latlng, f.latlng.to.df)) %>% 
         tidyr::unnest(latlng)
      
   } else {
      df.stream <- tmp.wide %>% 
         tidyr::unnest()
   }
   
   if (!is.null(id)) {
      df.stream %>% dplyr::mutate(id = id)
   } else {
      df.stream  
   }
}
