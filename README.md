
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

The functions are in two categories depending on ease of use.  The first category of functions scrape data from the public Strava website and the second category uses the API functions.  The second category also requires an authentication token.  The help files for each category can be viewed using ```help.search```:


```r
help.search('notoken', package = 'rStrava')
help.search('token', package = 'rStrava')
```


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
## Jun 2014      Jul      Aug      Sep      Oct      Nov      Dec Jan 2015 
##   423.95   514.30   625.50   298.85   653.30   298.85   430.90   382.25 
##      Feb      Mar      Apr      May      Jun 
##   333.60   479.55   486.50   437.85   111.20 
## 
## $`2837007`$year_to_date
##       Distance           Time Elevation Gain          Rides 
##      2241.2000       134.5833     10384.0000       184.0000 
## 
## $`2837007`$all_time
##  Total Distance      Total Time Total Elev Gain     Total Rides 
##       9381.8000        541.0333      59295.0000        698.0000 
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
## Jun 2014      Jul      Aug      Sep      Oct      Nov      Dec Jan 2015 
## 136.8500 215.0500 241.1167 267.1833 143.3667 221.5667 625.6000 371.4500 
##      Feb      Mar      Apr      May      Jun 
## 540.8833 156.4000   0.0000   0.0000   0.0000 
## 
## $`2527465`$year_to_date
##       Distance           Time Elevation Gain          Rides 
##        1067.50          59.75       17955.00          40.00 
## 
## $`2527465`$all_time
##  Total Distance      Total Time Total Elev Gain     Total Rides 
##       6662.4000        349.7333     109611.0000        301.0000
```

More info forthcoming...

### License

This package is released in the public domain under the creative commons license [CC0](https://tldrlegal.com/license/creative-commons-cc0-1.0-universal). 
