############
# functions for rStrava

############
# text mining functions, not through strava API
# no login or authentication required

######
# get units of measurement
# 'xml' is HTMLInternalDocument from getURL
# used in athl_fun
units_fun <- function(xml_in){
  
  # dependencies
  if(!require(XML)) install.packages('XML')
  library(XML)
  
  uni_val <- xpathSApply(xml_in, "//abbr[@class='unit']", xmlValue)
  uni_val <- unique(uni_val)
  
  return(uni_val)
  
}

######
# get distances for last twelve months
# 'prsd' is list form athl_fun
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

######
# get summary data - year to date and total
# 'prsd' is list created within athl_fun
# output is two-element list 
summ_fun <- function(prsd){
  
  if(!require(plyr)) install.packages('plyr')
  library(plyr)
  
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

######
# get athlete location
# input is xml from URL
# used in athl_fun
loc_fun <- function(xml_in){
  
  # dependencies
  if(!require(XML)) install.packages('XML')
  library(XML)
  
  loc_val <- xpathSApply(xml_in, "//div[@class='location']", xmlValue)
  loc_val <- gsub('\\n|[[:space:]]*$', '', loc_val)
  
  return(loc_val)
  
}

######
# get recent achievements
# input is xml from URL
# used in athl_fun
# currently does not work
achv_fun <- function(xml_in){

  achv_val <- xpathSApply(xml_in, 
                          "//section//[@class='athlete-achievements']", xmlValue)
#   loc_val <- gsub('\\n|[[:space:]]*$', '', loc_val)
  
  return(achv_val)
  
}

######
# get XML data for an athlete w/o logging in
# athl_num is numeric value for id
# output is two-element list, first is parsed XML, second is chr string of units
athl_fun <- function(athl_num){
  
  # dependencies
  if(!require(XML)) install.packages('XML')
  library(XML)
  
  if(!require(RCurl)) install.packages('RCurl')
  library(RCurl)
  
  # get unparsed url text using input
  url_in <- paste0('http://www.strava.com/athletes/', athl_num)
  
  athl_exists <- url.exists(url_in)
  
  if(!athl_exists) stop('Athlete does not exist')
  
  # get page data for athlete
  athl_url <- getURL(url_in)
  
  # url as HTMLInternalDoc
  prsd <- htmlTreeParse(athl_url, useInternalNodes = T)
  
  # get units of measurement
  unts <- units_fun(prsd)
  
  # get athlete location
  loc <- loc_fun(prsd)
  
  prsd <- list(parsed = prsd, units = unts, location = loc)
  
  # monthly data from bar plot
  monthly <- monthly_fun(prsd)
  
  # year to date and all time summary
  summ <- summ_fun(prsd)
  
  # output
  out <- list(
    id = athl_num, 
    units = unts, 
    location = loc, 
    monthly = monthly, 
    year_to_date = summ[['year_to_date']],
    all_time = summ[['all_time']]
  )
  return(out)
  
}

############
# functions for accessing data through strava api
# authentication required
# credit to: https://github.com/ptdrow/Rtrava

######
# oauth2.0 authentication for accessing strava app
# returns authentication token used as input to data retrieval functions
# 'app_name', 'client_id', and 'client_secret' are assigned to user when registering their app
# visit http://www.strava.com/developers, http://strava.github.io/api/
# 'app_name' is chr string of name of app to access
# 'client_id' is chr string of assigned client id
# 'client_secret' is chr string of client secret
# 'scope' is chr string of 'public', 'write', 'view_private', or 'view_private,write'
rStrava_oauth <- function(app_name, client_id, client_secret, scope = NULL){

	# oath2 application
	app <- oauth_app('rStrava', key, app_secret)  
	
	# oauth2 end point
	endpt <- oauth_endpoint(
		request = "https://www.strava.com/oauth/authorize?",
		authorize = "https://www.strava.com/oauth/authorize",
		access = "https://www.strava.com/oauth/token")

	# oauth2 token
	out <- config(token = oauth2.0_token(endpt, app, scope = scope))

	return(out)
	
	}

######
# get basic athlete info (yourself) via v3/athlete
# 'token' is oauth2 access token, returned from 'rStrava_oauth'
# returns list athlete data
athlete <- function(token){

	# response class
	raw <- GET('https://www.strava.com/api/v3/athlete', token)
	
	# parse response
	parsed <- content(raw)
	
	# return output
	return(parsed)
	
	}

######
# get athlete info of someone else via /v3/athletes/:id
# 'id' is athlete number
# 'token' is oath2 authentication token from 'rStrava_oauth'
athlete_id <- function(id, token){
	
	# response class
	url_in <- paste0('https://www.strava.com/api/v3/athletes/', id)
	raw <- GET(url_in, token)
	
	# parse response
	parsed <- content(raw)
	
	# return output
	return(parsed)
	
	}










