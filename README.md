
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
## $`2837007`$current_month
##   Distance       Time  Elevation 
##  97.700000   6.133333 102.000000 
## 
## $`2837007`$monthly
## Mar 2015      Apr      May      Jun      Jul      Aug      Sep      Oct 
## 481.5214 488.5000 439.6500 558.2857 516.4143 558.2857 544.3286 683.9000 
##      Nov      Dec Jan 2016      Feb      Mar 
## 425.6929 397.7786 439.6500 341.9500  97.7000 
## 
## $`2837007`$year_to_date
##       Distance           Time Elevation Gain          Rides 
##      828.50000       53.58333     1404.00000       71.00000 
## 
## $`2837007`$all_time
##  Total Distance      Total Time Total Elev Gain     Total Rides 
##      13588.6000        801.3833      85938.0000        989.0000 
## 
## 
## $`2527465`
## $`2527465`$units
## [1] "km" "h"  "m"  "m" 
## 
## $`2527465`$location
## [1] "Caracas, Distrito Metropolitano de Caracas, Venezuela"
## 
## $`2527465`$current_month
##  Distance      Time Elevation 
## 191.50000  15.56667 962.00000 
## 
## $`2527465`$monthly
## Jul 2014      Aug      Sep      Oct      Nov      Dec Jan 2015      Feb 
##   259.05   290.45   321.85   172.70   266.90   753.60   447.45   651.55 
##      Mar      Apr      May      Jun      Jul 
##   188.40     0.00     0.00     0.00    15.70 
## 
## $`2527465`$year_to_date
##       Distance           Time Elevation Gain          Rides 
##        1083.30          61.15       18108.00          41.00 
## 
## $`2527465`$all_time
##  Total Distance      Total Time Total Elev Gain     Total Rides 
##       6678.2000        351.1167     109764.0000        302.0000
```

#### API functions

These functions require a Strava account and a personal API, both of which can be obtained on the Strava website.  The user account can be created by following instructions on the [Strava homepage](https://www.strava.com/).  After the account is created, a personal API can be created under API tab of [profile settings](https://www.strava.com/settings/api).  The user must have an application name (chosen by the user), client id (different from the athlete id), and an application secret to create the authentication token.  Additional information about the personal API can be found [here](https://strava.github.io/api/).  Every API retrieval function in the rStrava package requires an authentication token (called `stoken` in the help documents).  The following is a suggested workflow for using the API functions with rStrava.

First, create the authentication token using your personal information from your API.  Replace the `app_name`, `app_client_id`, and `app_secret` objects with the relevant info from your account.

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
## $username
## [1] "beck_marcus"
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
## [1] "https://dgalywyr863hv.cloudfront.net/pictures/athletes/2837007/900880/4/medium.jpg"
```

### License

This package is released in the public domain under the creative commons license [CC0](https://tldrlegal.com/license/creative-commons-cc0-1.0-universal). 

### To do
check date format for `get_efforts_list`, is there an easy way to get athlete, segment, club id numbers?
