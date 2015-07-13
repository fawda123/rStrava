
# rStrava

##### *Marcus W. Beck, mbafs2012@gmail.com, Pedro Villarroel, pedrodvf@gmail.com*

### Overview and Installation

This is the development repository for rStrava, an R package to access data from the Strava API.  The package can be installed and loaded as follows:


```r
install.packages('devtools')
devtools::install_github('fawda123/rStrava')
```

### Issues and suggestions

Please report any issues and suggestions on the [issues link](https://github.com/fawda123/rStrava/issues) for the repository.

Linux: [![Travis-CI Build Status](https://travis-ci.org/fawda123/rStrava.svg?branch=master)](https://travis-ci.org/fawda123/rStrava)

Windows: [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/fawda123/rStrava?branch=master)](https://ci.appveyor.com/project/fawda123/rStrava)

### Package overview

The functions are in two categories depending on mode of use.  The first category of functions scrape data from the public Strava website and the second category uses the API functions.  The second category requires an authentication token.  The help files for each category can be viewed using ```help.search```:


```r
help.search('notoken', package = 'rStrava')
help.search('token', package = 'rStrava')
```

#### Scraping functions

An example using the scraping functions:


```r
# get athlete data for these guys
athl_fun(c(2837007, 2527465), trace = FALSE)
```

```
## $`2837007`
## $`2837007`$units
## [1] "mi" "h"  "m"  "ft"
## 
## $`2837007`$location
## [1] "Pensacola, FL"
## 
## $`2837007`$monthly
## Jul 2014      Aug      Sep      Oct      Nov      Dec Jan 2015      Feb 
## 521.2067 633.9000 302.8633 662.0733 302.8633 436.6867 387.3833 338.0800 
##      Mar      Apr      May      Jun      Jul 
## 485.9900 493.0333 443.7300 563.4667 211.3000 
## 
## $`2837007`$year_to_date
##       Distance           Time Elevation Gain          Rides 
##         2886.1          173.1        12897.0          226.0 
## 
## $`2837007`$all_time
##  Total Distance      Total Time Total Elev Gain     Total Rides 
##        10026.70          579.55        61808.00          740.00 
## 
## 
## $`2527465`
## $`2527465`$units
## [1] "km" "h"  "m" 
## 
## $`2527465`$location
## [1] "Caracas, Distrito Metropolitano de Caracas, Venezuela"
## 
## $`2527465`$monthly
## Jul 2014      Aug      Sep      Oct      Nov      Dec Jan 2015      Feb 
## 215.0500 241.1167 267.1833 143.3667 221.5667 625.6000 371.4500 540.8833 
##      Mar      Apr      May      Jun      Jul 
## 156.4000   0.0000   0.0000   0.0000   0.0000 
## 
## $`2527465`$year_to_date
##       Distance           Time Elevation Gain          Rides 
##        1067.50          59.75       17955.00          40.00 
## 
## $`2527465`$all_time
##  Total Distance      Total Time Total Elev Gain     Total Rides 
##       6662.4000        349.7333     109611.0000        301.0000
```

#### API functions

These functions require a Strava account and a personal API, both of which can be obtained on the Strava website.  The user account can be created by following instruction on the [Strava homepage](https://www.strava.com/).  After the account is created, a personal API can be created under API tab of [profile settings](https://www.strava.com/settings/api).  The user must have an application name (chosen by the user), client id (different from the athlete id), and an application secret to create the authentication token.  Additional information about the peronsal API can be found [here](https://strava.github.io/api/).  Every API retrieveal function in the rStrava package requires an authentication token.  The following is a suggest workflow for using the API functions with rStrava.

First, create the authentication token using your personal information from your API.  Replace the `app_name`, `app_client_id`, and `app_secret` objects with the relevant info.

```r
app_name <- 'myappname' # chosen by user
app_client_id  <- 'myid' # an integer, assigned by Strava
app_secret <- 'xxxxxxxx' # an alphanumeric secret, assigned by Strava

# create the authentication token
stoken <- httr::config(token = strava_oauth(app_name, app_client_id, app_secret))
```

The API retrieval functions can be used after the token is created.


```r
myinfo <- get_athlete(stoken, id = '2837007')
head(myinfo)
```

```
## $id
## [1] 2837007
## 
## $resource_state
## [1] 3
## 
## $firstname
## [1] "Marcus"
## 
## $lastname
## [1] "Beck"
## 
## $profile_medium
## [1] "https://dgalywyr863hv.cloudfront.net/pictures/athletes/2837007/900880/2/medium.jpg"
## 
## $profile
## [1] "https://dgalywyr863hv.cloudfront.net/pictures/athletes/2837007/900880/2/large.jpg"
```

### License

This package is released in the public domain under the creative commons license [CC0](https://tldrlegal.com/license/creative-commons-cc0-1.0-universal). 
