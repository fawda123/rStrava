#' calculates cumulative distance from activity longitude latitude points
#' 
#' calculates cumulative distance from activity longitude latitude points
#' 
#' @param data the data frame containing the latitude and longitude points
#' @param lon the column name for your longitude points
#' @param lat the column name for your latitude points
#' @return vector of cumulative distances
#' @author Daniel Padfield
#' @concept token
#' @export

distance <- function(data, lon, lat){
		dat <- data[,c(lon, lat)]
		x <- sapply(2:nrow(dat), function(y){geosphere::distm(dat[y-1,], dat[y,])/1000})
		return(c(0, cumsum(x)))
	}