
# rStrava

##### *Marcus W. Beck, mbafs2012@gmail.com, Pedro Villarroel, pedrodvf@gmail.com, Daniel Padfield*

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

The functions are in three categories depending on mode of use.  The first category of functions scrape data from the public Strava website and the second category uses the API functions or relies on data from the API functions.  The second category requires an authentication token.  The help files for each category can be viewed using ```help.search```:


```r
help.search('notoken', package = 'rStrava')
```

```
## starting httpd help server ...
```

```
##  done
```

```r
help.search('token', package = 'rStrava')
```

#### Scraping functions (no token)

An example using the scraping functions:


```r
# get athlete data for these guys
athl_fun(c(2837007, 2527465, 2140248), trace = FALSE)
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
##  Distance      Time Elevation 
##    131.70      9.35    809.00 
## 
## $`2837007`$monthly
## Sep 2015      Oct      Nov      Dec Jan 2016      Feb      Mar      Apr 
## 540.6632 679.2947 422.8263 395.1000 436.6895 339.6474 457.4842 457.4842 
##      May      Jun      Jul      Aug      Sep 
## 360.4421 457.4842 464.4158 318.8526 131.7000 
## 
## $`2837007`$year_to_date
##       Distance           Time Elevation Gain          Rides 
##         3295.1          205.0        18274.0          251.0 
## 
## $`2837007`$all_time
##  Total Distance      Total Time Total Elev Gain     Total Rides 
##         16055.2           952.8        102808.0          1169.0 
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
## 233.60000  13.33333 853.00000 
## 
## $`2527465`$monthly
##   Sep 2015        Oct        Nov        Dec   Jan 2016        Feb 
##   50.05714  300.34286  266.97143  383.77143   33.37143  183.54286 
##        Mar        Apr        May        Jun        Jul        Aug 
##  400.45714  400.45714  650.74286  350.40000  417.14286 1618.51429 
##        Sep 
##  233.60000 
## 
## $`2527465`$year_to_date
##       Distance           Time Elevation Gain          Rides 
##      4385.4000       235.2333     42212.0000       102.0000 
## 
## $`2527465`$all_time
##  Total Distance      Total Time Total Elev Gain     Total Rides 
##      12249.3000        668.6833     161874.0000        438.0000 
## 
## 
## $`2140248`
## $`2140248`$units
## [1] "km" "h"  "m"  "m" 
## 
## $`2140248`$location
## [1] "Falmouth, England, United Kingdom"
## 
## $`2140248`$current_month
##   Distance       Time  Elevation 
##  318.10000   13.58333 3724.00000 
## 
## $`2140248`$monthly
##   Sep 2015        Oct        Nov        Dec   Jan 2016        Feb 
## 342.107547 534.167925  66.020755   0.000000 138.043396   6.001887 
##        Mar        Apr        May        Jun        Jul        Aug 
##  78.024528 396.124528 240.075472 306.096226 558.175472 318.100000 
##        Sep 
##   0.000000 
## 
## $`2140248`$year_to_date
##       Distance           Time Elevation Gain          Rides 
##     1992.40000       83.13333    23422.00000       70.00000 
## 
## $`2140248`$all_time
##  Total Distance      Total Time Total Elev Gain     Total Rides 
##       6531.2000        277.0333      79752.0000        471.0000
```

#### API functions (token)

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
## $city
## [1] "Pensacola"
```

An example creating a heat map of activities:

```r
library(dplyr)

# get activities, compile, filter by location
acts <- get_activity_list(stoken, '2837007') %>% 
	compile_activities %>% 
	filter(location_city %in% c('Pensacola', 'Pensacola Beach'))

get_heat_map(acts)
```

![](README_files/figure-html/unnamed-chunk-8-1.png)<!-- -->


### License

This package is released in the public domain under the creative commons license [CC0](https://tldrlegal.com/license/creative-commons-cc0-1.0-universal). 
