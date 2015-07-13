############
# functions for accessing data through strava api
# authentication required
# credit to: https://github.com/ptdrow/Rtrava

# The token should be configured to work in the httr functions. Use the next line of code to configure it.
# stoken <- config(token = strava_oauth(app_name, app_client_id, app_secret, app_scope))

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





