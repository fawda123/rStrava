######
# testing and examples for rStrava
# Sep. 2014

######
# test non-api functions

source('funcs.r')

# check if athletes exist, I have no idea what max number is
athl_chks <- 1:2000000
athl_chks <- sample(athl_chks, 30)
system.time({
  for(val in 1:length(athl_chks)){
    cat(val, '\t')
    athl_num <- athl_chks[val]
    try_athl <- try(athl_fun(athl_num))
    if('try-error' %in% class(try_athl)) athl_chks[val] <- NA_real_
    }
  }
)

# try some random athletes
rand <- sample(1:2e6, 1)
athl_xml <- athl_fun(rand)
athl_xml

######
# test api functions

# get authentication token to access functions
# 'app_name', 'id', 'secret' were assigned to me
# other users will have to get their own values by registering an app on strava
# visit http://www.strava.com/developers, http://strava.github.io/api/
token <- rStrava_oauth(app_name, id, secret)

# get my information
my_data <- athlete(token)

# get someone else's information
other_data <- athlete_id('111111', token)


