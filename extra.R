# https://github.com/andreiolariu/data-mining-strava/blob/master/get_athlete_info.py

# somethign about a header, see the forked Python script
if(url.exists("http://www.strava.com/athletes/2377487/profile_sidebar_comparison?hl=en-US")) {
  h = basicHeaderGatherer()
  getURI("http://www.strava.com/athletes/2377487/profile_sidebar_comparison?hl=en-US",
         headerfunction = h$update)
  names(h$value())
  h$value()
}
GET("http://httpbin.org/basic-auth/user/passwd",
    authenticate("user", "passwd"))

# this line should be removed from history
GET('https://www.strava.com/login', authenticate('username', 'password')
    
    
    # pretty sure the headers are correct here
    # see http://en.wikipedia.org/wiki/List_of_HTTP_header_fields
    hd_nms <- c('X-Requested-With', 'Accept')
    hd_vls <- c('XMLHttpRequest', 'text/javascript, application/javascript, application/ecmascript, application/x-ecmascript')
    names(hd_vls) <- hd_nms
    
    # this works, sorta
    res <- GET('http://www.strava.com/athletes/11111/profile_sidebar_comparison?hl=en-US', 
               add_headers(hd_vls))
