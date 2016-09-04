#' Decode Google polyline of an activity into latitude and longitude
#' 
#' Decodes Google's polyline that are given in get_activity() and get_activity_list()
#' 
#' @author Max
#' @param Google_polyline character element of Google polyline of an activity
#' @return A vector of latitudes an longitudes in decimals separated by a comma
#' @concept notoken
#' @details When getting an activity using get_activity() a Google polyline is returned as one of the outputs. This function converts the polyline into latitude and longitude coordinates suitable for plotting
#' @export
#' @references https://s4rdd.blogspot.co.uk/2012/12/google-maps-api-decoding-polylines-for.html?showComment=1473004506791#c3610119369153401460

decode_Polyline <- function(Google_polyline){
	
	vlen <- nchar(Google_polyline)
	vindex <- 0
	varray <- NULL
	vlat <- 0
	vlng <- 0
	
	while(vindex < vlen){
		vb <- NULL
		vshift <- 0
		vresult <- 0
		repeat{
			if(vindex + 1 <= vlen){
				vindex <- vindex + 1
				vb <- as.integer(charToRaw(substr(Google_polyline, vindex, vindex))) - 63
			}
			
			vresult <- bitops::bitOr(vresult, bitops::bitShiftL(bitops::bitAnd(vb, 31), vshift))
			vshift <- vshift + 5
			if(vb < 32) break
		}
		
		dlat <- ifelse(
			bitops::bitAnd(vresult, 1)
			, -(bitops::bitShiftR(vresult, 1)+1)
			, bitops::bitShiftR(vresult, 1)
		)
		vlat <- vlat + dlat
		
		vshift <- 0
		vresult <- 0
		repeat{
			if(vindex + 1 <= vlen) {
				vindex <- vindex+1
				vb <- as.integer(charToRaw(substr(Google_polyline, vindex, vindex))) - 63
			}
			
			vresult <- bitops::bitOr(vresult, bitops::bitShiftL(bitops::bitAnd(vb, 31), vshift))
			vshift <- vshift + 5
			if(vb < 32) break
		}
		
		dlng <- ifelse(
			bitops::bitAnd(vresult, 1)
			, -(bitops::bitShiftR(vresult, 1)+1)
			, bitops::bitShiftR(vresult, 1)
		)
		vlng <- vlng + dlng
		
		varray <- rbind(varray, c(vlat * 1e-5, vlng * 1e-5))
	}
	coords <- data.frame(varray)
	names(coords) <- c("lat", "lon")
	coords <- tidyr::unite(coords, latlon, c(lat, lon), sep = ',')
	return(coords)
}