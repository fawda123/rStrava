#' Makes a heat map from your activity data
#' 
#' Makes a heat map from your activity data
#' 
#' @author Daniel Padfield, Marcus Beck
#' 
#' @concept token
#' 
#' @param act_data an activities list object returned by \code{\link{get_activity_list}}, an \code{actframe} returned by \code{\link{compile_activities}}, or a \code{strfame} returned by \code{\link{get_activity_streams}} 
#' @param key chr string of Google API key for elevation data, passed to \code{\link[googleway]{google_elevation}} for polyline decoding, see details
#' @param acts numeric indicating which activities to plot based on index in the activities list, defaults to most recent
#' @param id optional numeric vector to specify the id(s) of the activity/activities to plot, \code{acts} is ignored if provided
#' @param alpha the opacity of the line desired. A single activity should be 1. Defaults to 0.5
#' @param add_elev logical indicating if elevation is overlayed by color shading on the activity lines
#' @param as_grad logical indicating if elevation is plotted as percent gradient, applies only if \code{add_elev = TRUE}
#' @param filltype chr string specifying which stream variable to use for filling line segments, applies only to \code{strframe} objects, acceptable values are \code{"elevation"}, \code{"distance"}, \code{"slope"}, or \code{"speed"}
#' @param distlab logical if distance labels are plotted along the route
#' @param distval numeric indicating rounding factor for distance labels which has direct control on label density, see details 
#' @param size numeric indicating width of activity lines
#' @param col chr string indicating either a single color of the activity lines if \code{add_grad = FALSE} or a color palette passed to \code{\link[ggplot2]{scale_fill_distiller}} if \code{add_grad = TRUE}
#' @param expand a numeric multiplier for expanding the number of lat/lon points on straight lines.  This can create a smoother elevation gradient if \code{add_grad = TRUE}.  Set \code{expand = 1} to suppress this behavior.  
#' @param maptype chr string indicating the provider for the basemap, see details
#' @param zoom numeric indicating zoom factor for map tiles, higher numbers increase resolution
#' @param units chr string indicating plot units as either metric or imperial, this has no effect if input data are already compiled with \code{\link{compile_activities}}
#' @param ... arguments passed to or from other methods
#' 
#' @details uses \code{\link{get_latlon}} to produce a dataframe of latitudes and longitudes to use in the map. Uses ggspatial to produce the map and ggplot2 to plot the route.
#' 
#' A Google API key is needed for the elevation data and must be included with function execution.  The API key can be obtained following the instructions here: https://developers.google.com/maps/documentation/elevation/#api_key
#'
#' The \code{distval} argument is passed to the \code{digits} argument of \code{round}. This controls the density of the distance labels, e.g., 1 will plot all distances in sequence of 0.1, 0 will plot all distances in sequence of one, -1 will plot all distances in sequence of 10, etc. 
#' 
#' The base map type is selected with the \code{maptype} argument.  The \code{zoom} value specifies the resolution of the map.  Use higher values to download map tiles with greater resolution, although this increases the download time.  Acceptable options for \code{maptype} include \code{"OpenStreetMap"}, \code{"OpenStreetMap.DE"}, \code{"OpenStreetMap.France"}, \code{"OpenStreetMap.HOT"}, \code{"OpenTopoMap"}, \code{"Esri.WorldStreetMap"}, \code{"Esri.DeLorme"}, \code{"Esri.WorldTopoMap"}, \code{"Esri.WorldImagery"}, \code{"Esri.WorldTerrain"}, \code{"Esri.WorldShadedRelief"}, \code{"Esri.OceanBasemap"}, \code{"Esri.NatGeoWorldMap"}, \code{"Esri.WorldGrayCanvas"}, \code{"CartoDB.Positron"}, \code{"CartoDB.PositronNoLabels"}, \code{"CartoDB.PositronOnlyLabels"}, \code{"CartoDB.DarkMatter"}, \code{"CartoDB.DarkMatterNoLabels"}, \code{"CartoDB.DarkMatterOnlyLabels"}, \code{"CartoDB.Voyager"}, \code{"CartoDB.VoyagerNoLabels"}, or \code{"CartoDB.VoyagerOnlyLabels"}.
#'
#' @return A \code{\link[ggplot2]{ggplot}} object showing a map with activity locations.
#' 
#' @export
#' 
#' @import magrittr
#' 
#' @examples 
#' \dontrun{
#' # get my activities
#' stoken <- httr::config(token = strava_oauth(app_name, app_client_id, app_secret, cache = TRUE))
#' my_acts <- get_activity_list(stoken)
#' 
#' # default, requires Google key
#' mykey <- 'Get Google API key'
#' get_heat_map(my_acts, acts = 1, alpha = 1, key = mykey)
#' 
#' # plot elevation on locations, requires key
#' get_heat_map(my_acts, acts = 1, alpha = 1, key = mykey, add_elev = TRUE, col = 'Spectral', size = 2)
#' 
#' # compile first, change units
#' my_acts <- compile_activities(my_acts, acts = 156, units = 'imperial')
#' get_heat_map(my_acts, key = mykey, alpha = 1, add_elev = T, col = 'Spectral', size = 2)
#' }
get_heat_map <- function(act_data, ...) UseMethod('get_heat_map')

#' @rdname get_heat_map
#'
#' @export
#'
#' @method get_heat_map list
get_heat_map.list <- function(act_data, key, acts = 1, id = NULL, alpha = NULL, add_elev = FALSE, as_grad = FALSE, distlab = TRUE, distval = 0, size = 0.5, col = 'red', expand = 10, maptype = 'CartoDB.Positron', zoom = 14, units = 'metric', ...){
	
	# compile
	act_data <- compile_activities(act_data, acts = acts, id = id, units = units)

	get_heat_map.actframe(act_data, alpha = alpha, key = key, add_elev = add_elev, as_grad = as_grad, distlab = distlab, distval = distval, size = size, col = col, expand = expand, maptype = maptype, zoom = zoom, ...)	
	
}
	
#' @rdname get_heat_map
#'
#' @export
#'
#' @method get_heat_map actframe
get_heat_map.actframe <- function(act_data, key, alpha = NULL, add_elev = FALSE, as_grad = FALSE, distlab = TRUE, distval = 0, size = 0.5, col = 'red', expand = 10, maptype = 'CartoDB.Positron', zoom = 14, ...){

	# get unit types and values attributes
	unit_type <- attr(act_data, 'unit_type')
	unit_vals <- attr(act_data, 'unit_vals')

	# check maptype
	maptype <- match.arg(maptype, c("OpenStreetMap", "OpenStreetMap.DE", "OpenStreetMap.France", 
																	"OpenStreetMap.HOT", "OpenTopoMap",
																	"Esri.WorldStreetMap", "Esri.DeLorme", "Esri.WorldTopoMap", 
																	"Esri.WorldImagery", "Esri.WorldTerrain", "Esri.WorldShadedRelief", 
																	"Esri.OceanBasemap", "Esri.NatGeoWorldMap", "Esri.WorldGrayCanvas", 
																	"CartoDB.Positron", "CartoDB.PositronNoLabels", 
																	"CartoDB.PositronOnlyLabels", "CartoDB.DarkMatter", 
																	"CartoDB.DarkMatterNoLabels", "CartoDB.DarkMatterOnlyLabels", 
																	"CartoDB.Voyager", "CartoDB.VoyagerNoLabels", "CartoDB.VoyagerOnlyLabels"))
	
	# warning if units conflict
	args <- as.list(match.call())
	if('units' %in% names(args))
		if(args$units != unit_type)
			warning('units does not match unit type, use compile_activities with different units')
				
	if(is.null(alpha)) alpha <- 0.5

	# remove rows without polylines
	act_data <- chk_nopolyline(act_data)

	# data to plot
	temp <- act_data %>% 
		dplyr::group_by(upload_id) %>%
		tidyr::nest() %>% 
		mutate(locs = purrr::map(data, function(x) get_latlon(x$map.summary_polyline, key = key))) %>% 
		dplyr::select(-data) %>%
		dplyr::ungroup() %>% 
		tidyr::unnest(locs) %>% 
		dplyr::rename(activity = upload_id)

	# get distances, default is km
	temp <- dplyr::group_by(temp, activity) %>%
		dplyr::mutate(distance = get_dists(lon, lat)) %>% 
		dplyr::ungroup()

	if(unit_type %in% 'imperial'){
		temp$distance <- temp$distance * 0.621371
		temp$ele <- temp$ele *  3.28084
	}
	
	# create as spatvector for tiles
	tempsv <- tidyterra::as_spatvector(temp[, c('lon', 'lat')], crs = 4326)
	tls <- maptiles::get_tiles(x = tempsv, provider = maptype, zoom = zoom, )

	# base plot
	pbase <- ggplot2::ggplot() +
		tidyterra::geom_spatraster_rgb(data = tls, maxcell = 1e8) +
		ggplot2::theme(axis.title = ggplot2::element_blank())
	
	# add elevation to plot
	if(add_elev){
		
		# plot gradient 
		if(as_grad){
			
			# get gradient
			temp <- dplyr::mutate(temp, EleDiff = c(0, diff(ele)),
														distdiff = c(0, diff(distance)),
														grad = c(0, (EleDiff[2:nrow(temp)]/10)/distdiff[2:nrow(temp)]))

			p <- pbase +
				ggspatial::geom_spatial_path(ggplot2::aes(x = lon, y = lat, group = activity, colour = grad), 
																		 alpha = alpha, data = temp, linewidth = size, crs = 4326) +
				ggplot2::scale_colour_distiller('Gradient (%)', palette = col)
		
		# plot elevation			
		} else {
			
			# legend label for elevation
			leglab <- paste0('Elevation (', unit_vals['elevation'], ')')
			
			p <- pbase +
				ggspatial::geom_spatial_path(ggplot2::aes(x = lon, y = lat, group = activity, colour = ele), 
													 alpha = alpha, data = temp, linewidth = size, crs = 4326) +
				ggplot2::scale_colour_distiller(leglab, palette = col)
			
		}
			
	# otherwise dont		
	} else {
		
		p <- pbase +
			ggspatial::geom_spatial_path(ggplot2::aes(x = lon, y = lat, group = activity), 
																	 alpha = alpha, data = temp, linewidth = size, colour = col, crs = 4326)
		
	}

	# plot distances
	if(distlab){

		# get distances closes to integers, add final distance
		disttemp <- temp %>% 
			dplyr::mutate(
				tosel = round(distance, distval), 
				diffdist = abs(distance - tosel)
			) %>% 
			dplyr::group_by(activity, tosel) %>% 
			dplyr::filter(diffdist == min(diffdist)) %>% 
			dplyr::ungroup(.) %>% 
			dplyr::select(-tosel, -diffdist) %>% 
			dplyr::mutate(distance = as.character(round(distance)))
		# final <- temp[nrow(temp), ] 
		# final$distance <- format(final$distance, nsmall = 1, digits = 1)
		# disttemp <- rbind(disttemp, final)

		# add to plot
		p <- p + 
			ggspatial::geom_spatial_label_repel(
				data = disttemp, 
				ggplot2::aes(x = lon, y = lat, label = distance),
				point.padding = grid::unit(0.4, "lines"), 
				crs = 4326
				)
		
	}
	
	p <- p +
		ggplot2::coord_sf(xlim = range(temp$lon), ylim = range(temp$lat))
	
	return(p)
	
}

#' @rdname get_heat_map
#'
#' @export
#'
#' @method get_heat_map strframe
get_heat_map.strframe <- function(act_data, alpha = NULL, filltype = 'elevation', distlab = TRUE, distval = 0, size = 0.5, col = 'red', expand = 10, maptype = 'CartoDB.Positron', zoom = 14, ...){

	# get unit types and values attributes
	unit_type <- attr(act_data, 'unit_type')
	unit_vals <- attr(act_data, 'unit_vals')
	
	# check maptype
	maptype <- match.arg(maptype, c("OpenStreetMap", "OpenStreetMap.DE", "OpenStreetMap.France", 
																	"OpenStreetMap.HOT", "OpenTopoMap",
																	"Esri.WorldStreetMap", "Esri.DeLorme", "Esri.WorldTopoMap", 
																	"Esri.WorldImagery", "Esri.WorldTerrain", "Esri.WorldShadedRelief", 
																	"Esri.OceanBasemap", "Esri.NatGeoWorldMap", "Esri.WorldGrayCanvas", 
																	"CartoDB.Positron", "CartoDB.PositronNoLabels", 
																	"CartoDB.PositronOnlyLabels", "CartoDB.DarkMatter", 
																	"CartoDB.DarkMatterNoLabels", "CartoDB.DarkMatterOnlyLabels", 
																	"CartoDB.Voyager", "CartoDB.VoyagerNoLabels", "CartoDB.VoyagerOnlyLabels"))
	
	# warning if units conflict
	args <- as.list(match.call())
	if('units' %in% names(args))
		if(args$units != unit_type)
			warning('units argument ignored for strframe objects')
	
	# get filltype
	filltype <- match.arg(filltype, c('elevation', 'distance', 'slope', 'speed'))
	
	if(is.null(alpha)) alpha <- 0.5

	# data to plot
	# expand values for each activity
	temp <- act_data
	temp <- split(temp, temp$id)
	temp <- lapply(temp, function(x) {

		xint <- stats::approx(x = x$lng, n = expand * nrow(x))$y
		yint <- stats::approx(x = x$lat, n = expand * nrow(x))$y
		dist <- stats::approx(x= x$distance, n = expand * nrow(x))$y
		alti <- stats::approx(x= x$altitude, n = expand * nrow(x))$y
		grds <- stats::approx(x= x$grade_smooth, n = expand * nrow(x))$y
		vels <- stats::approx(x= x$velocity_smooth, n = expand * nrow(x))$y
		data.frame(id = unique(x$id), lat = yint, lng = xint, distance = dist, elevation = alti, slope = grds, speed = vels)
		
	})
	temp <- do.call('rbind', temp)

	# create as spatvector for tiles
	tempsv <- tidyterra::as_spatvector(temp[, c('lon', 'lat')], crs = 4326)
	tls <- maptiles::get_tiles(x = tempsv, provider = maptype, zoom = zoom)
	
	# base plot
	pbase <- ggplot2::ggplot() +
		tidyterra::geom_spatraster_rgb(data = tls, maxcell = 1e8) +
		ggplot2::theme(axis.title = ggplot2::element_blank())

	# legend and plot
	if(filltype == 'slope') leglab <- '%'
	else leglab <- unit_vals[filltype]
	p <- pbase +
		ggspatial::geom_spatial_path(ggplot2::aes_string(x = 'lng', y = 'lat', group = 'id', colour = filltype), 
											 alpha = alpha, data = temp, linewidth = size, crs = 4326) +
		ggplot2::scale_colour_distiller(leglab, palette = col)

	# plot distances
	if(distlab){
		
		# get distances closes to integers, add final distance
		disttemp <- temp %>% 
			dplyr::mutate(
				tosel = round(distance, distval), 
				diffdist = abs(distance - tosel)
			) %>% 
			dplyr::group_by(id, tosel) %>% 
			dplyr::filter(diffdist == min(diffdist)) %>% 
			dplyr::ungroup(.) %>% 
			dplyr::select(-tosel, -diffdist) %>% 
			dplyr::mutate(distance = as.character(round(distance)))
		# final <- temp[nrow(temp), ] 
		# final$distance <- format(final$distance, nsmall = 1, digits = 1)
		# disttemp <- rbind(disttemp, final)
		
		# add to plot
		p <- p + 
			ggspatial::geom_spatial_label_repel(
				data = disttemp, 
				ggplot2::aes(x = lng, y = lat, label = distance),
				point.padding = grid::unit(0.4, "lines"), 
				crs = 4326
			)
		
	}
	
	return(p)
	
}