# rStrava 1.3.2

* Added a `NEWS.md` file
* Require all `id` arguments as character for issue #104
* Update details documentation for `get_activity_streams()` if bad request for issue #105
* Fix to precision issue for long integer output to character in parsed requests for issue #106, added jsonlite depends
* Removed RCurl depends

# rStrava 1.3.1

* Fix to `compile_activity()` if input is from a request to `get_activity_list()` using activity id, output will match that if request is by date range
* Removed plyr and prettymapr package dependencies
* Removed ggspatial basemaps and replaced with methods from maptiles and tidyterra packages in `get_heat_map()`
* Fixed bug retrieving activity titles in `recent_fun()` when retrieving athlete info with no token

# rStrava 1.3.0

* Fix to `athl_fun()` (#99) for scraping user profile content. Monthly summaries are no longer available.  Information on trophies and achievements have been added.
* Removed ggmap and ggrepel dependencies, replaced with ggspatial functions to retrieve basemap tiles in `get_heat_map()`.  This is a breaking change as arguments to `get_heat_map()` were modified.  The `f` and `source` arguments were removed and options for `maptype` were changed. A `zoom` argument was also added.

# rStrava 1.2.0

* Fix to output from `compile_activities()` if units are imperial and elevation data are missing
* Replaced deprecated calls to `as.tibble()` with `as_tibble()`
* `type` argument in `get_streams()` is checked with valid entries
* Units for `type` argument for `get_streams()` added to help documentation
* Clarification in documentation for merging behavior of the `series_type()` argument in `get_streams()`
* Fix to `get_heat_map()` function for proper passing of the `source` argument to `ggmap`

# rStrava 1.1.4

* Initial CRAN release
* added `get_laps()` function to retrieve lap data for an individual activity
* now depends on R v3.5.0

# rStrava 1.1.3

* Fixed a bug with `athlind_fun()` to correctly parse XML attribute for the athlete data
* Check added to `get_activity_streams()` that exits function if manual entries are requested from the user
* Added an optional `id` argument to `compile_activities()`, `get_activity_streams()`, `get_elev_prof()`, `get_heat_map()`,  and `plot_spdsplits()` to request results for an activity using the id value, rather than the index value

# rStrava 1.1.2

* Added an optional `id` argument to several functions to select an activity by its actual id value, rather than the order in which it appears in the `my_acts` object
* Bug fix to types argument in `get_activity_streams()` that was returning an error with incorrect `tidyr::unnest()`

# rStrava 1.1.1

* Added informative error message if bad request from Google API
* Updated examples in help files for `get_latlon()`, `get_dists()`, `get_elev_prof()`, `get_heat_map()`
* Updated `app_scope` parameter definition to use new values following Strava's updates to the API which are mandatory from October 2019, an appropriate `app_scope` is now required
* Added required `app_scope` to authentication token request following Strava's updates to the API which are mandatory from October 2019, an appropriate `app_scope` is now required
* Added informative error message if settings are private for `athlind_fun()`
* Fixed bug if `numeric(0)` in `get_streams data()`, replaced with `NA` to `unnest()`
* Updated documentation for `get_activity_streams()` about `type` arg
* Updated documentation for `athl_fun()` and `athlind_fun()` to correctly say what is returned

# rStrava 1.1.0

* Quicker polyline decoding using googleway package improves performance
* Added functionality for retrieving club data, including `compile_club_activities()`
* Fixes to `get_segment()` and `compile_segment()` for correct request arguments
* Other minor bug fixes, see commit log

# rStrava 1.0.1

* Fix to `month_fun()` to return `NA` if info is unavailable, added `location_fun()`

# rStrava 1.0.0

* Major fix to `athl_fun()`