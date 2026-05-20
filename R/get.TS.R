getSigmaInit <- function(id) {
    if (is.null(id)) 10 else rep(10, length(unique(id)))
}

#' Reconstruct water level
#'
#' Estimate the model parameters and return the estimated water levels.
#' This is the RTMB-powered version of the original tsHydro::get.TS.
#' @param dat A data.frame containing at least the columns: time, height, and track
#' @param init.h Initial value for the mean water levels. The default value is 0.
#' @param init.logsigmarw Initial value for the log of the standard deviation of the random walk
#' @param init.logSigma Initial value for the log of the standard deviation of the observation noise
#' @param bias Optional, vector of length N-1 with initial values of the bias estimates, where N is the number of satellite missions used. To estimate the bias "dat" must have a column "satid" with the ids of the satellites for each observation, 0,1,2,3,..,N-1. The number of bias estimates is N-1. The bias estimates are w.r.t. the satellite with the largest id. If dat$satid is provided the observation standard deviation is estimated per satellite.
#' @param init.logit Initial value for the logit of the outlier fraction
#' @param priorHeight Optional length-1 vector with a prior mean on the water level.
#' @param priorSd Optional length-1 vector with a prior sd on the water level.
#' @param estP Logical, \code{FALSE} keeps the outlier fraction fixed at its initial value.
#' @param silent Logical, passed to \code{RTMB::MakeADFun}.
#' @param weights Optional vector of weights.
#' @param varPerTrack Optional logical: if TRUE, an observation standard deviation "logSigma" is estimated per track.
#' @param varPerQuality Optional logical: if TRUE, an observation standard deviation "logSigma" is estimated per quality id. If this option is used "dat" must have a column named "qf".
#' @param newdat Optional data frame including at least a column named "time" containing the time in decimal years where the modeled water level is predicted. newdat may also include a column named "group" with a group id for each observation.
#' @param ... Additional entries passed into the parameter map for \code{RTMB::MakeADFun}.
#' @details The function can handle the observation-based standard deviation in different ways: per satellite, per track, or per quality. However, these options cannot be used together.
#' @return An object of class "tsHydro".
#' @keywords time series
#' @import RTMB
#' @export
#' @examples
#' \dontrun{
#' data(lakelevels)
#' fit <- get.TS(lakelevels)
#' }
get.TS <- function(dat, init.h = 0, init.logsigmarw = 0,
                   init.logSigma = getSigmaInit(dat$satid),
                   bias = rep(0, length(unique(dat$satid)) - 1),
                   init.logit = log(0.1 / (1 - 0.1)), priorHeight = numeric(0),
                   priorSd = numeric(0),
                   estP = FALSE, silent = TRUE,
                   weights = rep(1, nrow(dat)),
                   varPerTrack = FALSE,
                   varPerQuality = FALSE,
                   newdat = NULL,
                   ...) {

    if (is.null(dat$satid)) dat$satid <- rep(0, nrow(dat))
    if (is.null(dat$qf))    dat$qf    <- rep(0, nrow(dat))
    if (is.null(dat$hsd))   dat$hsd   <- rep(NA, nrow(dat))
    sorttime <- sort(unique(c(dat$time, newdat$time)))

    o <- order(dat$track)
    dat <- dat[o, ]

    obsfrom <- sapply(unique(dat$track), function(i) min(which(dat$track == i))) - 1
    obsto   <- sapply(unique(dat$track), function(i) max(which(dat$track == i))) - 1
    obsn    <- obsto - obsfrom + 1

    data <- list(
        height       = dat$height,
        times        = sorttime,
        timeidx      = match(dat$time, sorttime),
        newtimeidx   = match(newdat$time, sorttime),
        group        = if (!is.null(newdat$group)) newdat$group else numeric(0),
        trackinfo    = cbind(obsfrom, obsto, obsn),
        satid        = dat$satid,
        qfid         = dat$qf,
        hsd          = dat$hsd,
        weights      = weights[o],
        priorHeight  = priorHeight,
        priorSd      = priorSd,
        varPerTrack  = ifelse(varPerTrack, 1L, 0L),
        varPerQuality = ifelse(varPerQuality, 1L, 0L),
        trackidx     = as.integer(as.factor(dat$track)) - 1L
    )

    if (varPerTrack) {
        init.logSigma <- getSigmaInit(dat$track)
    }

    if (varPerQuality) {
        init.logSigma <- getSigmaInit(dat$qf)
    }

    parameters <- list(
        logSigma   = init.logSigma,
        logSigmaRW = init.logsigmarw,
        logitp     = init.logit,
        u          = rep(init.h, length(data$times)),
        bias       = bias
    )

    mymap <- list(logitp = factor(ifelse(estP, 1, NA)), ...)
    if (!any(is.na(dat$hsd))) mymap$logSigma <- factor(NA)

    nll <- tsHydro_nll(data)

    obj <- RTMB::MakeADFun(nll, parameters, random = "u",
                           map = mymap, silent = silent)

    opt <- nlminb(obj$par, obj$fn, obj$gr)

    rep <- RTMB::sdreport(obj)
    pl   <- as.list(rep, "Est")
    plsd <- as.list(rep, "Std")
    newdat$est <- pl$u[data$newtimeidx]
    newdat$sd  <- plsd$u[data$newtimeidx]
    pl$u   <- pl$u[unique(data$timeidx)]
    plsd$u <- plsd$u[unique(data$timeidx)]
    obstimes <- data$times[unique(data$timeidx)]
    groupAve <- data.frame(Est = as.list(rep, "Est", report = TRUE)$groupAve,
                           Std = as.list(rep, "Std", report = TRUE)$groupAve)
    ret <- list(pl = pl, plsd = plsd, data = data, opt = opt, obj = obj,
                aveH   = rep$value[names(rep$value) == "aveH"],
                sdAveH = rep$sd[names(rep$value) == "aveH"],
                newdat = newdat, obstimes = obstimes, groupAve = groupAve)
    class(ret) <- "tsHydro"
    ret
}
