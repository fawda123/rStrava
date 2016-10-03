
# rStrava

##### *Marcus W. Beck, mbafs2012@gmail.com, Pedro Villarroel, pedrodvf@gmail.com, Daniel Padfield, dp323@exeter.ac.uk*

Linux: [![Travis-CI Build Status](https://travis-ci.org/fawda123/rStrava.svg?branch=master)](https://travis-ci.org/fawda123/rStrava)

Windows: [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/fawda123/rStrava?branch=master)](https://ci.appveyor.com/project/fawda123/rStrava)

![](api_logo_pwrdBy_strava_horiz_light.png)

### Overview and installation

This is the development repository for rStrava, an R package to access data from the Strava API.  The package can be installed and loaded as follows:


```r
install.packages('devtools')
devtools::install_github('fawda123/rStrava')
```

### Issues and suggestions

Please report any issues and suggestions on the [issues link](https://github.com/fawda123/rStrava/issues) for the repository.

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
##  Distance      Time Elevation 
##     11.20      0.65      0.00 
## 
## $`2837007`$monthly
## Oct 2015      Nov      Dec Jan 2016      Feb      Mar      Apr      May 
##    548.8    341.6    319.2    352.8    274.4    369.6    369.6    291.2 
##      Jun      Jul      Aug      Sep      Oct 
##    369.6    375.2    257.6    358.4     11.2 
## 
## $`2837007`$year_to_date
##       Distance           Time Elevation Gain          Rides 
##      3615.8000       226.0167     19757.0000       277.0000 
## 
## $`2837007`$all_time
##  Total Distance      Total Time Total Elev Gain     Total Rides 
##      16375.9000        973.8167     104291.0000       1195.0000 
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
##   Distance       Time  Elevation 
##  401.30000   22.61667 1633.00000 
## 
## $`2527465`$monthly
##   Oct 2015        Nov        Dec   Jan 2016        Feb        Mar 
##  300.97500  267.53333  384.57917   33.44167  183.92917  401.30000 
##        Apr        May        Jun        Jul        Aug        Sep 
##  401.30000  652.11250  351.13750  418.02083 1621.92083  401.30000 
##        Oct 
##    0.00000 
## 
## $`2527465`$year_to_date
##       Distance           Time Elevation Gain          Rides 
##         4553.1          244.5        42993.0          110.0 
## 
## $`2527465`$all_time
##  Total Distance      Total Time Total Elev Gain     Total Rides 
##        12417.10          677.95       162655.00          446.00 
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
##    Distance        Time   Elevation 
##  167.100000    7.416667 2025.000000 
## 
## $`2140248`$monthly
##   Oct 2015        Nov        Dec   Jan 2016        Feb        Mar 
## 531.139286  65.646429   0.000000 137.260714   5.967857  77.582143 
##        Apr        May        Jun        Jul        Aug        Sep 
## 393.878571 238.714286 304.360714 555.010714 316.296429  53.710714 
##        Oct 
## 167.100000 
## 
## $`2140248`$year_to_date
##       Distance           Time Elevation Gain          Rides 
##        2211.90          92.55       26080.00          73.00 
## 
## $`2140248`$all_time
##  Total Distance      Total Time Total Elev Gain     Total Rides 
##       6750.7000        286.4333      82410.0000        474.0000
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
get_heat_map(my_acts, acts = which(acts), source = 'osm', col = 'darkgreen', size = 2)
```

![](README_files/figure-html/unnamed-chunk-8-1.png)<!-- -->

```r
# plot elevation along a single ride
get_heat_map(my_acts, acts = 6, alpha = 1, add_elev = T, f = 1, key = mykey, size = 2, col = 'Spectral', maptype = 'satellite')
```

![](README_files/figure-html/unnamed-chunk-8-2.png)<!-- -->

```r
# plot % gradient along a single ride
get_heat_map(my_acts, acts = 6, alpha = 1, add_elev = T, f = 1, as_grad = T, key = mykey, size = 2, col = 'Spectral', expand = 5, maptype = 'satellite')
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
