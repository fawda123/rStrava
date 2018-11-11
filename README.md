
# rStrava

##### *Marcus W. Beck, mbafs2012@gmail.com, Pedro Villarroel, pedrodvf@gmail.com, Daniel Padfield, dp323@exeter.ac.uk, Lorenzo Gaborini, lorenzo.gaborini@unil.ch, Niklas von Maltzahn, niklasvm@gmail.com*

Linux: [![Travis-CI Build Status](https://travis-ci.org/fawda123/rStrava.svg?branch=master)](https://travis-ci.org/fawda123/rStrava)

Windows: [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/fawda123/rStrava?branch=master)](https://ci.appveyor.com/project/fawda123/rStrava)

[![DOI](https://zenodo.org/badge/23404183.svg)](https://zenodo.org/badge/latestdoi/23404183)

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

The functions are in two categories depending on mode of use.  The first category of functions scrape data from the public Strava website and the second category uses the API functions or relies on data from the API functions.  The second category requires an authentication token.  The help files for each category can be viewed using ```help.search```:


```r
help.search('notoken', package = 'rStrava')
help.search('token', package = 'rStrava')
```

### Scraping functions (no token)

An example using the scraping functions:


```r
# get athlete data 
athl_fun(2837007, trace = FALSE)
```

```
## $`2837007`
## $`2837007`$units
## [1] "mi" "h"  "m"  "ft"
## 
## $`2837007`$location
## [1] "Irvine, California"
## 
## $`2837007`$current_month
##    Distance        Time   Elevation 
##  113.500000    7.633333 1230.000000 
## 
## $`2837007`$monthly
## Nov 2017      Dec Jan 2018      Feb      Mar      Apr      May      Jun 
## 227.0000 259.4286 283.7500 299.9643 364.8214 275.6429 308.0714 235.1071 
##      Jul      Aug      Sep      Oct      Nov 
## 389.1429 287.8036 360.7679 332.3929 113.5000 
## 
## $`2837007`$year_to_date
##       Distance           Time Elevation Gain          Rides 
##      2886.0000       188.0667     37730.0000       269.0000 
## 
## $`2837007`$all_time
##  Total Distance      Total Time Total Elev Gain     Total Rides 
##         23393.0          1436.4        187746.0          1819.0
```

### API functions (token)

#### Setup 

These functions require a Strava account and a personal API, both of which can be obtained on the Strava website.  The user account can be created by following instructions on the [Strava homepage](https://www.strava.com/).  After the account is created, a personal API can be created under API tab of [profile settings](https://www.strava.com/settings/api).  The user must have an application name (chosen by the user), client id (different from the athlete id), and an application secret to create the authentication token.  Additional information about the personal API can be found [here](https://strava.github.io/api/).  Every API retrieval function in the rStrava package requires an authentication token (called `stoken` in the help documents).  The following is a suggested workflow for using the API functions with rStrava.

First, create the authentication token using your personal information from your API.  Replace the `app_name`, `app_client_id`, and `app_secret` objects with the relevant info from your account.

```r
app_name <- 'myappname' # chosen by user
app_client_id  <- 'myid' # an integer, assigned by Strava
app_secret <- 'xxxxxxxx' # an alphanumeric secret, assigned by Strava

# create the authentication token
stoken <- httr::config(token = strava_oauth(app_name, app_client_id, app_secret))
```

Setting `cache = TRUE` for `strava_oauth` will create an authentication file in the working directory. This can be used in later sessions as follows:

```r
stoken <- httr::config(token = readRDS('.httr-oauth')[[1]])
```

Finally, the `get_heat_map` and `get_elev_prof` functions optionally retrieve elevation data from the Google Maps Elevation API. To use these features, an additional authentication key is required.  Follow the instructions [here](https://developers.google.com/maps/documentation/elevation/#api_key).  The key can be added to the R environment file for later use:


```r
# save the key, do only once
cat("google_key=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n",
    file=file.path(normalizePath("~/"), ".Renviron"),
    append=TRUE)

# retrieve the key, restart R if not found
mykey <- Sys.getenv("google_key")
```

The `get_heat_map` function uses [ggmap](https://github.com/dkahle/ggmap) to create base maps.  A Google API key is needed if using any map services where `source = "google"` for the argument to `get_heat_map`.  The same key used for the Elevation API can be used but must be registered externally with the ggmap package using `register_google()` before executing `get_heat_map`.



```r
library(ggmap)
register_google(mykey)
```

#### Using the functions

The API retrieval functions are used with the token.

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
## [1] "Irvine"
```

An example creating a heat map of activities:

```r
library(dplyr)

# get activities, get activities by lat/lon, plot
my_acts <- get_activity_list(stoken)
act_data <- compile_activities(my_acts) %>% 
	filter(start_longitude < -86.5 & start_longitude > -88.5) %>% 
	filter(start_latitude < 31.5 & start_latitude > 30)
get_heat_map(act_data, col = 'darkgreen', size = 2, distlab = F, f = 0.4)
```

![](README_files/figure-html/unnamed-chunk-11-1.png)<!-- -->

Plotting elevation and grade for a single ride:

```r
# plot elevation along a single ride
get_heat_map(my_acts, acts = 1, alpha = 1, add_elev = T, f = 0.3, key = mykey, size = 2, col = 'Spectral', maptype = 'satellite', units = 'imperial')
```

![](README_files/figure-html/unnamed-chunk-12-1.png)<!-- -->

```r
# plot % gradient along a single ride
get_heat_map(my_acts, acts = 1, alpha = 1, add_elev = T, f = 0.3, as_grad = T, key = mykey, size = 2, col = 'Spectral', expand = 5, maptype = 'satellite', units = 'imperial')
```

![](README_files/figure-html/unnamed-chunk-12-2.png)<!-- -->

Get elevation profiles for activities:

```r
# get activities
my_acts <- get_activity_list(stoken) 

get_elev_prof(my_acts, acts = 1, key = mykey, units = 'imperial')
```

![](README_files/figure-html/unnamed-chunk-13-1.png)<!-- -->

```r
get_elev_prof(my_acts, acts = 1, key = mykey, units = 'imperial', total = T)
```

![](README_files/figure-html/unnamed-chunk-13-2.png)<!-- -->

Plot average speed per split (km or mile) for an activity:

```r
# plots for most recent activity
plot_spdsplits(my_acts, stoken, acts = 1, units = 'imperial')
```

![](README_files/figure-html/unnamed-chunk-14-1.png)<!-- -->

Additional functions are provided to get "stream" information for individual activities.  Streams provide detailed information about location, time, speed, elevation, gradient, cadence, watts, temperature, and moving status (yes/no) for an individual activity.

Use `get_activity_streams` for detailed info about activites:

```r
# get streams for the first activity in my_acts
strms_data <- get_activity_streams(my_acts, stoken, acts = 1)
head(strms_data)
```

```
##   altitude distance grade_smooth moving time velocity_smooth      lat
## 1     35.3   0.0000          0.8  FALSE    0            0.00 33.72606
## 2     35.3   0.0063          0.6   TRUE    3            7.56 33.72603
## 3     35.4   0.0133          0.4   TRUE    6            7.92 33.72598
## 4     35.4   0.0173          0.5   TRUE    8            7.92 33.72595
## 5     35.4   0.0230          0.0   TRUE   10            8.64 33.72591
## 6     35.4   0.0262          0.0   TRUE   11            9.36 33.72588
##         lng         id
## 1 -117.7823 1953105389
## 2 -117.7822 1953105389
## 3 -117.7822 1953105389
## 4 -117.7822 1953105389
## 5 -117.7821 1953105389
## 6 -117.7821 1953105389
```

Stream data can be plotted using any of the plotting functions.

```r
# heat map
get_heat_map(strms_data, alpha = 1, filltype = 'speed', f = 0.3, size = 2, col = 'Spectral', distlab = F)
```

![](README_files/figure-html/unnamed-chunk-16-1.png)<!-- -->


```r
# elevation profile
get_elev_prof(strms_data)
```

![](README_files/figure-html/unnamed-chunk-17-1.png)<!-- -->

```r
# speed splits
plot_spdsplits(strms_data, stoken)
```

![](README_files/figure-html/unnamed-chunk-17-2.png)<!-- -->

### License

This package is released in the public domain under the creative commons license [CC0](https://tldrlegal.com/license/creative-commons-cc0-1.0-universal). 
