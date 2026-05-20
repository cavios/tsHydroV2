#' Lake-level satellite altimetry data
#'
#' Satellite altimetry observations of a small lake, suitable for testing
#' [get.TS()]. 5,433 observations.
#'
#' @format A data frame with the following columns:
#' \describe{
#'   \item{height}{Observed water level (m).}
#'   \item{lake}{Lake identifier (integer).}
#'   \item{track}{Satellite track identifier (integer).}
#'   \item{time}{Observation time in decimal years.}
#' }
#' @keywords datasets
"lakelevels"

#' Nam Co lake-level satellite altimetry data
#'
#' Satellite altimetry observations of Lake Nam Co on the Tibetan Plateau,
#' suitable for testing [get.TS()]. 8,476 observations.
#'
#' @format A data frame with the following columns:
#' \describe{
#'   \item{height}{Observed water level (m above ellipsoid).}
#'   \item{lake}{Lake identifier (integer).}
#'   \item{track}{Satellite track identifier (integer).}
#'   \item{time}{Observation time in decimal years.}
#' }
#' @keywords datasets
"namco"
