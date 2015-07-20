############
# functions for accessing data through strava api
# authentication required
# credit to: https://github.com/ptdrow/Rtrava

# The token should be configured to work in the httr functions. Use the next line of code to configure it.
# stoken <- config(token = strava_oauth(app_name, app_client_id, app_secret, app_scope))

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





