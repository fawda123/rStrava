% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_athlete.R
\name{get_athlete}
\alias{get_athlete}
\title{Get basic data for an athlete}
\usage{
get_athlete(stoken, id = NULL)
}
\arguments{
\item{stoken}{A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function}

\item{id}{string of athlete}
}
\value{
A list of athlete information including athlete name, location, followers, etc. as described here: \url{https://strava.github.io/api/v3/athlete/}.
}
\description{
Get basic athlete data for an athlete using an API request
}
\details{
Requires authentication stoken using the \code{\link{strava_oauth}} function and a user-created API on the strava website.
}
\examples{
\dontrun{
# create authentication token
# requires user created app name, id, and secret from Strava website
stoken <- httr::config(token = strava_oauth(app_name, app_client_id, 
	app_secret, cache = TRUE))

get_athlete(stoken, id = '2527465')
}
}
\concept{token}
