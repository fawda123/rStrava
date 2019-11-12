
# rStrava

##### *Marcus W. Beck, <mbafs2012@gmail.com>, Pedro Villarroel, <pedrodvf@gmail.com>, Daniel Padfield, <dp323@exeter.ac.uk>, Lorenzo Gaborini, <lorenzo.gaborini@unil.ch>, Niklas von Maltzahn, <niklasvm@gmail.com>*

[![Travis-CI Build
Status](https://travis-ci.org/fawda123/rStrava.svg?branch=master)](https://travis-ci.org/fawda123/rStrava)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/fawda123/rStrava?branch=master)](https://ci.appveyor.com/project/fawda123/rStrava)
[![DOI](https://zenodo.org/badge/23404183.svg)](https://zenodo.org/badge/latestdoi/23404183)

<img src="man/figures/api_logo_pwrdBy_strava_horiz_light.png" align="left" width="300" />
<br></br> <br></br>

### Overview and installation

This is the development repository for rStrava, an R package to access
data from the Strava API. The package can be installed and loaded as
follows:

``` r
install.packages('devtools')
devtools::install_github('fawda123/rStrava')
```

### Issues and suggestions

Please report any issues and suggestions on the [issues
link](https://github.com/fawda123/rStrava/issues) for the repository.

### Package overview

The functions are in two categories depending on mode of use. The first
category of functions scrape data from the public Strava website and the
second category uses the API functions or relies on data from the API
functions. The second category requires an authentication token. The
help files for each category can be viewed using `help.search`:

``` r
help.search('notoken', package = 'rStrava')
help.search('token', package = 'rStrava')
```

### Scraping functions (no token)

An example using the scraping functions is below. Some users may have
privacy settings that block public access to account data.

``` r
# get athlete data 
athl_fun(2837007, trace = FALSE)
```

    ## $`2837007`
    ## $`2837007`$name
    ## [1] "Marcus Beck"
    ## 
    ## $`2837007`$location
    ## [1] "Irvine, California"
    ## 
    ## $`2837007`$units
    ## [1] "mi" "ft"
    ## 
    ## $`2837007`$monthly
    ##        month     miles hours elev_gain
    ## 1 2019-05-01 351.16172    25      1266
    ## 2 2019-06-01 283.40678    21      1132
    ## 3 2019-07-01 273.54686    20       893
    ## 4 2019-08-01 342.39727    25      1126
    ## 5 2019-09-01 284.57744    20      1041
    ## 6 2019-10-01  48.97586     7       773
    ## 7 2019-11-01  56.55658     4       147
    ## 
    ## $`2837007`$recent
    ##           id           name type startDateLocal distance elevation
    ## 1 2859540960   Morning Ride ride     2019-11-11      3.5        18
    ## 2 2858493438 Afternoon Ride ride     2019-11-11     36.2       339
    ## 3 2858170842    Morning Run  run     2019-11-08      3.2        47
    ##   movingTime
    ## 1      16:29
    ## 2    2:21:55
    ## 3      23:36
    ## 
    ## $`2837007`$achievements
    ##                          description             timeago
    ## 1   2nd best estimated 1 mile effort 2019-11-09 12:01:09
    ## 2       3rd best estimated 1k effort 2019-11-09 12:01:09
    ## 3 3rd best estimated 1/2 mile effort 2019-11-09 12:01:09
    ## 4     3rd best estimated 400m effort 2019-11-09 12:01:09
    ## 5  2nd fastest time on 21-9st Sprint 2019-11-12 12:10:31

### API functions (token)

#### Setup

These functions require a Strava account and a personal API, both of
which can be obtained on the Strava website. The user account can be
created by following instructions on the [Strava
homepage](https://www.strava.com/). After the account is created, a
personal API can be created under API tab of [profile
settings](https://www.strava.com/settings/api). The user must have an
application name (chosen by the user), client id (different from the
athlete id), and an application secret to create the authentication
token. Additional information about the personal API can be found
[here](https://strava.github.io/api/). Every API retrieval function in
the rStrava package requires an authentication token (called `stoken` in
the help documents). The following is a suggested workflow for using the
API functions with rStrava.

First, create the authentication token using your personal information
from your API. Replace the `app_name`, `app_client_id`, and `app_secret`
objects with the relevant info from your account.

``` r
app_name <- 'myappname' # chosen by user
app_client_id  <- 'myid' # an integer, assigned by Strava
app_secret <- 'xxxxxxxx' # an alphanumeric secret, assigned by Strava

# create the authentication token
stoken <- httr::config(token = strava_oauth(app_name, app_client_id, app_secret, app_scope="activity:read_all"))
```

Setting `cache = TRUE` for `strava_oauth` will create an authentication
file in the working directory. This can be used in later sessions as
follows:

``` r
stoken <- httr::config(token = readRDS('.httr-oauth')[[1]])
```

Finally, the `get_heat_map` and `get_elev_prof` functions require a key
from the Google API. Follow the instructions
[here](https://developers.google.com/maps/documentation/elevation/#api_key).
The key can be added to the R environment file for later use:

``` r
# save the key, do only once
cat("google_key=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n",
    file=file.path(normalizePath("~/"), ".Renviron"),
    append=TRUE)

# retrieve the key, restart R if not found
mykey <- Sys.getenv("google_key")
```

The `get_heat_map` function uses
[ggmap](https://github.com/dkahle/ggmap) to create base maps. A Google
API key is needed to use the function. This key must be registered
externally with the ggmap package using `register_google()` before
executing `get_heat_map`.

``` r
library(ggmap)
register_google(mykey)
```

#### Using the functions

The API retrieval functions are used with the token.

``` r
myinfo <- get_athlete(stoken, id = '2837007')
head(myinfo)
```

    ## $id
    ## [1] 2837007
    ## 
    ## $username
    ## [1] "beck_marcus"
    ## 
    ## $resource_state
    ## [1] 2
    ## 
    ## $firstname
    ## [1] "Marcus"
    ## 
    ## $lastname
    ## [1] "Beck"
    ## 
    ## $city
    ## [1] "Irvine"

An example creating a heat map of activities:

``` r
library(dplyr)

# get activities, get activities by lat/lon, plot
my_acts <- get_activity_list(stoken)
act_data <- compile_activities(my_acts) %>% 
    filter(start_longitude < -86.5 & start_longitude > -88.5) %>% 
    filter(start_latitude < 31.5 & start_latitude > 30)
get_heat_map(act_data, key = mykey, col = 'darkgreen', size = 2, distlab = F, f = 0.4)
```

![](README_files/figure-gfm/unnamed-chunk-11-1.png)<!-- -->

Plotting elevation and grade for a single ride:

``` r
# plot elevation along a single ride
get_heat_map(my_acts, acts = 1, alpha = 1, add_elev = T, f = 0.3, key = mykey, size = 2, col = 'Spectral', maptype = 'satellite', units = 'imperial')
```

![](README_files/figure-gfm/unnamed-chunk-12-1.png)<!-- -->

``` r
# plot % gradient along a single ride
get_heat_map(my_acts, acts = 1, alpha = 1, add_elev = T, f = 0.3, as_grad = T, key = mykey, size = 2, col = 'Spectral', expand = 5, maptype = 'satellite', units = 'imperial')
```

![](README_files/figure-gfm/unnamed-chunk-12-2.png)<!-- -->

Get elevation profiles for activities:

``` r
# get activities
my_acts <- get_activity_list(stoken) 

get_elev_prof(my_acts, acts = 1, key = mykey, units = 'imperial')
```

![](README_files/figure-gfm/unnamed-chunk-13-1.png)<!-- -->

``` r
get_elev_prof(my_acts, acts = 1, key = mykey, units = 'imperial', total = T)
```

![](README_files/figure-gfm/unnamed-chunk-13-2.png)<!-- -->

Plot average speed per split (km or mile) for an activity:

``` r
# plots for most recent activity
plot_spdsplits(my_acts, stoken, acts = 1, units = 'imperial')
```

![](README_files/figure-gfm/unnamed-chunk-14-1.png)<!-- -->

Additional functions are provided to get “stream” information for
individual activities. Streams provide detailed information about
location, time, speed, elevation, gradient, cadence, watts, temperature,
and moving status (yes/no) for an individual activity.

Use `get_activity_streams` for detailed info about activites:

``` r
# get streams for the first activity in my_acts
strms_data <- get_activity_streams(my_acts, stoken, acts = 1)
```

    ## Warning: `cols` is now required.
    ## Please use `cols = c(altitude, distance, grade_smooth, latlng, moving, time, velocity_smooth)`

    ## Warning: The `.preserve` argument of `unnest()` is deprecated as of tidyr 1.0.0.
    ## All list-columns are now preserved
    ## This warning is displayed once per session.
    ## Call `lifecycle::last_warnings()` to see where this warning was generated.

    ## Warning: `cols` is now required.
    ## Please use `cols = c(altitude, distance, grade_smooth, moving, time, velocity_smooth)`

``` r
head(strms_data)
```

    ##   altitude distance grade_smooth      lat       lng moving time
    ## 1     34.6   0.0000         -1.4 33.72592 -117.7833  FALSE    0
    ## 2     34.6   0.0036         -2.0 33.72594 -117.7834   TRUE    7
    ## 3     34.5   0.0074         -1.5 33.72591 -117.7834   TRUE   12
    ## 4     34.3   0.0149         -0.9 33.72584 -117.7834   TRUE   14
    ## 5     34.3   0.0204         -0.4 33.72580 -117.7833   TRUE   15
    ## 6     34.4   0.0259          0.9 33.72576 -117.7833   TRUE   16
    ##   velocity_smooth         id
    ## 1            0.00 2420187776
    ## 2            1.80 2420187776
    ## 3            2.16 2420187776
    ## 4            5.76 2420187776
    ## 5            7.56 2420187776
    ## 6            9.00 2420187776

Stream data can be plotted using any of the plotting functions.

``` r
# heat map
get_heat_map(strms_data, alpha = 1, filltype = 'speed', f = 0.3, size = 2, col = 'Spectral', distlab = F)
```

![](README_files/figure-gfm/unnamed-chunk-16-1.png)<!-- -->

``` r
# elevation profile
get_elev_prof(strms_data)
```

![](README_files/figure-gfm/unnamed-chunk-17-1.png)<!-- -->

``` r
# speed splits
plot_spdsplits(strms_data, stoken)
```

![](README_files/figure-gfm/unnamed-chunk-17-2.png)<!-- -->

### Contributing

Please view our [contributing](.github/CONTRIBUTING.md) guidelines for
any changes or pull requests.

### License

This package is released in the public domain under the creative commons
license
[CC0](https://tldrlegal.com/license/creative-commons-cc0-1.0-universal).
