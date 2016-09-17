
# rStrava

##### *Marcus W. Beck, mbafs2012@gmail.com, Pedro Villarroel, pedrodvf@gmail.com, Daniel Padfield, dp323@exeter.ac.uk*

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
##   Distance       Time  Elevation 
##  227.60000   15.26667 1420.00000 
## 
## $`2837007`$monthly
## Sep 2015      Oct      Nov      Dec Jan 2016      Feb      Mar      Apr 
## 537.9636 675.9030 420.7152 393.1273 434.5091 337.9515 455.2000 455.2000 
##      May      Jun      Jul      Aug      Sep 
## 358.6424 455.2000 462.0970 317.2606 227.6000 
## 
## $`2837007`$year_to_date
##       Distance           Time Elevation Gain          Rides 
##      3387.8000       210.5167     18881.0000       258.0000 
## 
## $`2837007`$all_time
##  Total Distance      Total Time Total Elev Gain     Total Rides 
##      16147.8000        958.3167     103415.0000       1176.0000 
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
##     263.9      15.2    1033.0 
## 
## $`2527465`$monthly
##   Sep 2015        Oct        Nov        Dec   Jan 2016        Feb 
##   49.48125  296.88750  263.90000  379.35625   32.98750  181.43125 
##        Mar        Apr        May        Jun        Jul        Aug 
##  395.85000  395.85000  643.25625  346.36875  412.34375 1599.89375 
##        Sep 
##  263.90000 
## 
## $`2527465`$year_to_date
##       Distance           Time Elevation Gain          Rides 
##         4415.7          237.1        42391.0          103.0 
## 
## $`2527465`$all_time
##  Total Distance      Total Time Total Elev Gain     Total Rides 
##        12279.60          670.55       162053.00          439.00 
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
##  Distance      Time Elevation 
##      0.00      0.65      0.00 
## 
## $`2140248`$monthly
## Sep 2015      Oct      Nov      Dec Jan 2016      Feb      Mar      Apr 
##        0        0        0        0        0        0        0        0 
##      May      Jun      Jul      Aug      Sep 
##        0        0        0        0        0 
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
# get activities, get activities by location, plot
my_acts <- get_activity_list(stoken)
acts <- lapply(my_acts, function(x) x$location_city) %in% c('Pensacola', 'Pensacola Beach', 'Milton') 
get_heat_map(my_acts, acts = which(acts), f = 0.1, size = 1)
```

![](README_files/figure-html/unnamed-chunk-8-1.png)<!-- -->

```r
# plot elevation along a single ride
get_heat_map(my_acts, acts = 5, alpha = 1, add_elev = T, key = mykey, size = 2, col = 'Spectral')
```

![](README_files/figure-html/unnamed-chunk-8-2.png)<!-- -->

```r
# plot % gradient along a single ride
get_heat_map(my_acts, acts = 5, alpha = 1, add_elev = T, as_grad = T, key = mykey, size = 2, col = 'Spectral', expand = 5)
```

![](README_files/figure-html/unnamed-chunk-8-3.png)<!-- -->

Get elevation profiles for activities:

```r
# get activities
my_acts <- get_activity_list(stoken) 

get_elev_prof(my_acts, acts = 1:2, key = mykey)
```

![](README_files/figure-html/unnamed-chunk-9-1.png)<!-- -->

```r
get_elev_prof(my_acts, acts = 1:2, key = mykey, total = T)
```

![](README_files/figure-html/unnamed-chunk-9-2.png)<!-- -->

### License

This package is released in the public domain under the creative commons license [CC0](https://tldrlegal.com/license/creative-commons-cc0-1.0-universal). 
