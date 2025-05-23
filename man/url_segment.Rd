% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/url_segment.R
\name{url_segment}
\alias{url_segment}
\title{Set the url for the different segment requests}
\usage{
url_segment(id = NULL, request = NULL)
}
\arguments{
\item{id}{character for id of the segment if \code{request = "all_efforts"} or \code{"leaderboard"}, or id of the athlete if \code{request = "starred"}, or NULL if using \code{request = "explore"} or \code{"starred"} of the athenticated user}

\item{request}{chr string, must be "starred", "all_efforts", "leaderboard", "explore" or NULL for segment details}
}
\value{
A url string.
}
\description{
Set the url for the different segment requests
}
\details{
Function is used internally within \code{\link{get_segment}}, \code{\link{get_starred}}, \code{\link{get_leaderboard}}, \code{\link{get_efforts_list}}, and \code{\link{get_explore}}
}
\examples{
url_segment()

url_segment(id = '123', request = 'leaderboard')
}
\concept{token}
