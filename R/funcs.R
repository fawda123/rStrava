############
# functions for rStrava

############
# functions for accessing data through strava api
# authentication required
# credit to: https://github.com/ptdrow/Rtrava

# Rtrava 0.5.0
# Library for the Strava API v3 in R

# Dependencies: httr.

# AUTHETICATION
# Generate a token for an user and the desired scope. It sends the user to the strava authentication page
# if he/she hasn't given permission to the app yet, else, is sent to the app webpage:
strava_oauth <- function(app_name, app_client_id, app_secret, app_scope = NULL,  cache = FALSE) {
      # app_name:      Name of the app (string)
      # app_client_id: ID received when the app was registered (string)
      # app_secret:    Secret received when the app was registered (string)
      # app_scope:     Scopes for the authentication (string)
      #                Must be "public" (or NULL), "write", "view_private", or "view_private,write"
      
      strava_app <- oauth_app(app_name, app_client_id, app_secret)  
      
      oauth2.0_token(oauth_endpoint(
            request = "https://www.strava.com/oauth/authorize?",
            authorize = "https://www.strava.com/oauth/authorize",
            access = "https://www.strava.com/oauth/token"),
            strava_app, scope = app_scope, cache = cache)
}

# The token should be configured to work in the httr functions. Use the next line of code to configure it.
# stoken <- config(token = strava_oauth(app_name, app_client_id, app_secret, app_scope))

# Use this line for the first time you use the get functions
# usage_left <- as.integer(c(600, 30000))

# RATE LIMIT
# Checks the ratelimit values after the last request and stores the left requests in a global variable
ratelimit <- function(req){
      # req: Output from the GET(...) function
      
      limit <- as.integer(strsplit(req$headers$`x-ratelimit-limit`, ",")[[1]])
      usage <- as.integer(strsplit(req$headers$`x-ratelimit-usage`, ",")[[1]])
      usage_left <<- limit - usage
}

# GET
# Getting data with requests that don't require for pagination
get_basic <- function(url_, stoken, queries = NULL){
      # url_:   URL to get data from (string)
      # stoken: Configured token (output from config(token = strava_oauth(...)))
      # queries: Specific additional queries or parameters (list)
      
      req <- GET(url_, stoken, query = queries)
      ratelimit(req)
      stop_for_status(req)
      dataRaw <- content(req)
      return (dataRaw)
}

# Getting several pages of one type of request
get_pages<-function(url_, stoken, per_page = 30, page_id = 1, page_max = 1, queries=NULL, All = FALSE){
      # url_:     URL to get data from (string)
      # stoken:   Configured token (output from config(token = strava_oauth(...)))
      # per_page: Number of items retrieved per page. Max=200 (integer)
      # page_id:  First page to get data from. (integer)
      # page_max: Max number of pages to get data from. (integer)
      # queries:  Specific additional queries or parameters (list)
      # All:      TRUE if you want all pages possible according to the number of pages and ratelimit (logic)
      
      dataRaw <- list()
      
      if(All){
            per_page=200 #reduces the number of requests
            page_id=1
            page_max=usage_left[1]
      }
      else if(page_max > usage_left[1]){#Trying to avoid exceeding the 15 min limit
            page_max <- usage_left[1]
            print (paste("The number of pages would exceed the rate limit, retrieving only"), usage_left[1], "pages")
      }      
      
      i = page_id - 1
      repeat{
            i <- i + 1
            req <- GET(url_, stoken, query = c(list(per_page=per_page, page=i), queries))
            ratelimit(req)
            stop_for_status(req)
            dataRaw <- c(dataRaw,content(req))
            if(length(content(req)) < per_page) {#breaks when the last page retrieved less items than the per_page value
                  break
            }
            if(i>=page_max) {#breaks when the max number of pages or ratelimit was reached
                  break
            }
      }
      return(dataRaw)
}

# ATHLETE
# Set the url of the athlete to get data from (according to its ID)
url_athlete <- function(id = NULL){
      # id: ID of the athlete (string or integer)
      #     Leaving the id = NULL will set the authenticated user URL
      
      url_ <- "https://www.strava.com/api/v3/athlete"
      if(!is.null(id))
            url_ <- paste(url_,"s/",id, sep = "")
      return(url_)
}

#Get the athlete's data
get_athlete <-function(stoken, id = NULL){
      # stoken: Configured token (output from config(token = strava_oauth(...)))
      # id:     ID of the athlete (string or integer)
      #         Leaving the id = NULL will get the authenticated user data
      
      dataRaw <- get_basic(url_athlete(id), stoken)
      return(dataRaw)
}

#Get the list of friends or followers from an user or the both-following according to another user
get_following <- function(following, stoken, id = NULL){
      # stoken:    Configured token (output from config(token = strava_oauth(...)))
      # following: Query. Must be equal to "friends", "followers" or "both-following"
      # id:        ID of the athlete (string or integer)
      
      url_ <- paste(url_athlete(id),"/", following, sep = "")
      dataRaw <- get_basic(url_, stoken)
      return(dataRaw)
}

#Get the list of KOMs/QOMs/CRs of an athlete
get_KOMs <- function(id, stoken){
      #id:     ID of the athlete (string or integer)
      #stoken: Configured token (output from config(token = strava_oauth(...)))
      
      url_ <- paste(url_athlete(id),"/koms", sep = "")
      dataRaw <- get_basic(url_, stoken)
      return(dataRaw)
}

#ACTIVITIES
#Set the url of activities for differents activities lists.
url_activities <- function(id=NULL, friends=FALSE, club=FALSE){
      #id:      ID of the activity or club if club=TRUE (string).
      #friends: TRUE if you want the friends activities of the authenticated user (logic)
      #club:    TRUE if you want the activities of a club (logic)
      
      url_ <- "https://www.strava.com/api/v3/activities/"
      if(!is.null(id)){
            if(club){#Url for the activities of the club with ID = id
                  url_ <- paste("https://www.strava.com/api/v3/clubs/", id,"/activities", sep="")
            }
            else{#Url for an specific activity
                  url_ <- paste(url_, id, sep = "")
            }
      }
      else if(friends){#Url for the activities of the authenticated user's friends
            url_ <- paste(url_,"following", sep = "")
      }
      else{#Url for the list of activities of the authenticated user
            url_ <- paste(url_athlete(),"/activities", sep = "")
      }
      
      return(url_)      
}

#Get the activities list of the desired type (club, friends, user)
get_activity_list <- function(stoken, id = NULL, club = FALSE, friends = FALSE){
      #stoken:  Configured token (output from config(token = strava_oauth(...)))
      #id:      ID of the activity or club if club=TRUE (string)
      #friends: TRUE if you want the friends activities of the authenticated user (logic)
      #club:    TRUE if you want the activities of a club (logic)
      
      #This codes assumes requesting all the pages of activities. In other circunstances change the parameters of 'get_pages'
      
      if (friends | club){
            dataRaw <- get_pages(url_activities(id = id, club = club, friends=friends), stoken, per_page = 200, page_id = 1, page_max = 1)
      }
      else{
            dataRaw <- get_pages(url_activities(), stoken, All=TRUE)
      }
      
      return(dataRaw)
}

#Get detailed data of an activity. It includes the segment efforts
get_activity <- function(id, stoken){
      # id:     ID of the required activity
      # stoken: Configured token (output from config(token = strava_oauth(...)))
      
      req <- GET(url_activities(id), stoken, query = list(include_all_efforts=TRUE)) 
      stop_for_status(req)
      dataRaw <- content(req)
      return(dataRaw)
}

#CLUBS
#Set the url of the clubs for the different requests
url_clubs <- function(id=NULL, request=NULL){
      # id:      ID of the club. If NULL gets the clubs of the authenticated athlete
      # request: must be "members", "activities" or NULL for club details
      
      if(is.null(id)){#Clubs of the authenticated athlete
            url_ <- paste(url_athlete(), "/clubs", sep = "")
      }
      else{ #request must be "members", "activities" or NULL for club details
            url_ <- paste("https://www.strava.com/api/v3/clubs/", id,"/", request, sep="")
      }
      return(url_)
}      

#Get the data according to the different requests or urls.
get_club <- function(stoken, id=NULL, request=NULL){
      # stoken:  Configured token (output from config(token = strava_oauth(...)))
      # id:      ID of the club. If NULL gets the clubs of the authenticated athlete
      # request: Must be "members", "activities" or NULL for club details
      
      if(is.null(id)){
            dataRaw <- get_basic(url_clubs(), stoken)
      }
      else{ 
            switch(request,
                   NULL = dataRaw <- get_basic(url_clubs(id), stoken),
                   
                   activities = dataRaw <- get_activity_list(stoken, id, club = TRUE),
                   
                   members = dataRaw <- get_pages(url_clubs(id = id, request = request), stoken,
                                                  per_page = 200, page_id = 1, page_max = 1)
            )
      }
      return(dataRaw)
}

#SEGMENTS
#Set the url for the different segment requests
url_segment <- function(id=NULL, request=NULL) {
      # id:      ID of the segment (for request= "all_efforts", "leaderboard")
      #          or ID of the athlete (in case using request="starred" of an selected athlete)
      #          or NULL (in case of using request="explore" or "starred" of the athenticated user)
      # request: Must be "starred", "all_efforts", "leaderboard", "explore" or NULL for segment details
      
      if(!is.null(request)){
            if(!is.null(id) & request == "starred"){
                  url_ <- paste("https://www.strava.com/api/v3/athlete/", id,"/segments/starred", sep="")
            }
            else{
                  url_ <- "https://www.strava.com/api/v3/segments/"
                  if(request == "starred" | request == "explore"){
                        url_ <- paste(url_, request, sep="")
                  }
                  else{
                        url_ <- paste(url_, id, "/", request, sep = "")
                  }
            }
      }
      else{
            url_ <- paste("https://www.strava.com/api/v3/segments/", id, sep="")
      }
      return(url_)
}

#Retrieve details about a specific segment.
get_segment <- function(stoken, id=NULL, request=NULL){
      #stoken: Configured token (output from config(token = strava_oauth(...)))
      #id:     ID of the segment
      
      dataRaw <- get_basic(url_segment(id), stoken)
      return(dataRaw)
}

# Retrieve a summary representation of the segments starred by an athlete
get_starred <- function(stoken, id=NULL){     
      #stoken: Configured token (output from config(token = strava_oauth(...)))
      #id:     ID of the athlete. If NULL gets the authenticate athlete
      
      dataRaw <- get_basic(url_segment(id=id, request="starred"), stoken)
      return(dataRaw)
}

#Retrieve the leaderboard of a segment
get_leaderboard <- function(stoken, id, nleaders=10, All=FALSE){
      #stoken:   Configured token (output from config(token = strava_oauth(...)))
      #id:       ID of the segment (string)
      #nleaders: Number of leaders to retrieve
      #All:      TRUE to retrieve all the list (logic)
      
      
      dataRaw <- get_pages(url_segment(id, request="leaderboard"), stoken, 
                           per_page = nleaders, All = All)
      return(dataRaw)
}

#Get all the efforts in a segment if no queries are specified
get_efforts_list <- function(stoken, id,athlete_id=NULL, start_date_local=NULL, end_date_local=NULL){
      #stoken:     Configured token (output from config(token = strava_oauth(...)))
      #id:         ID of the segment (string or integer)
      #athlete_id: ID of an athlete to filter the data (string or integer)
      #start_date_local and end_date_local are queries for filtering the data. Haven't check the required date format yet
      
      queries <- list(athlete_id=athlete_id,
                      start_date_local=start_date_local,
                      end_date_local=end_date_local)
      
      dataRaw <- get_pages(url_segment(id, request="all_efforts"), stoken, queries=queries, All=TRUE)
      return(dataRaw)
}

get_explore <- function(stoken, bounds, activity_type="riding", max_cat=NULL, min_cat=NULL){
      #stoken:        Configured token (output from config(token = strava_oauth(...)))
      #bounds:        string representing the comma separated list of bounding box corners 
      #               'sw.lat,sw.lng,ne.lat,ne.lng' 
      #               'south,west,north,east
      #               eg.: bounds="37.821362,-122.505373,37.842038,-122.465977"
      #activity_type: "riding" or "running"
      #max_cat:       integer representing the max climbing category
      #min_cat:       integer reprenenting the min climbing category
      
      url_ <- url_segment(request="explore")
      dataRaw <- get_basic(url_, stoken, queries=list(bounds=bounds,
                                                      activity_type=activity_type,
                                                      max_cat=max_cat,
                                                      min_cat=min_cat))
      return(dataRaw)
}

#STREAMS
#Set the url for the different requests of streams
url_streams  <- function(id, request="activities", types=list("latlng")){
      # id:      ID associated withe the request
      # request: Must be equal to "activities", "segment_efforts", or "segments"
      # types:   Must be a list with any combination of:
      #          "time", "latlng", "distance", "altitude", "velocity_smooth", "heartrate",
      #          "cadence", "watts", "temp", "moving" and "grade_smooth"
      
      #Converting the list of types into the proper string
      strtypes <- types[[1]]
      if(length(types)>1){
            for(i in 2:length(types)){
                  strtypes <- paste(strtypes,",", types[[i]], sep="")
            }
      }
      
      # Creating the url string
      url_ <- paste("https://www.strava.com/api/v3/", request, "/", id, "/streams/", strtypes, sep="")
      return(url_)
}

#Retrieve the streams
get_streams  <- function(stoken, id, request="activities",
                         types, resolution="all", series_type="distance"){
      # stoken:      Configured token (output from config(token = strava_oauth(...)))
      # id:          ID associated withe the request
      # request:     Must be equal to "activities", "segment_efforts", or "segments"
      # types:       Must be a list with any combination of:
      #              "time", "latlng", "distance", "altitude", "velocity_smooth", "heartrate",
      #              "cadence", "watts", "temp", "moving" and "grade_smooth"
      # resolution:  Query for the data to get. Can be "low", "medium", "high" or "all"
      # series_type: Query for merging the data if resolution != "all". Can be "distance" or "time"
      
      req <- GET(url_streams(id, request, types), stoken,
                 query = list(resolution=resolution, series_type=series_type))
      ratelimit(req)
      stop_for_status(req)
      dataRaw <- content(req)
      
      return(dataRaw)
}





