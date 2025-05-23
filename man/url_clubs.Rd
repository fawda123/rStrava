% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/url_clubs.R
\name{url_clubs}
\alias{url_clubs}
\title{Set the url of the clubs for the different requests}
\usage{
url_clubs(id = NULL, request = NULL)
}
\arguments{
\item{id}{character for id of the club, defaults to authenticated club of the athlete}

\item{request}{chr string, must be "members", "activities" or \code{NULL} for club details}
}
\value{
A url string.
}
\description{
Set the url of the clubs for the different requests
}
\details{
Function is used internally within \code{\link{get_club}}
}
\examples{
url_clubs()

url_clubs('123', request = 'members')
}
\concept{token}
