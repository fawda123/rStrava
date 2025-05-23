% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_starred.R
\name{get_starred}
\alias{get_starred}
\title{Retrieve a summary of the segments starred by an athlete}
\usage{
get_starred(stoken, id = NULL)
}
\arguments{
\item{stoken}{A \code{\link[httr]{config}} object created using the \code{\link{strava_oauth}} function}

\item{id}{character for id of the athlete, defaults to authenticated athlete}
}
\value{
Data from an API request.
}
\description{
Retrieve a summary of the segments starred by an athlete
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

get_starred(stoken)
}
}
\concept{token}
