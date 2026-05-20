#' @keywords internal
#' @importFrom stats nlminb
#' @importFrom utils write.table
#' @importFrom graphics points lines arrows
#' @importFrom grDevices gray
#' @import RTMB
"_PACKAGE"

## These names are injected into the model closure by `RTMB::getAll(data, parms)`
## and are not visible to `R CMD check`'s static analyser. Declaring them here
## suppresses the "no visible binding for global variable" notes.
utils::globalVariables(c(
    ## fields of the `data` list:
    "times", "height", "trackinfo", "priorHeight", "priorSd",
    "timeidx", "satid", "qfid", "hsd", "weights",
    "trackidx", "varPerTrack", "varPerQuality",
    "group", "newtimeidx",
    ## fields of the `parms` list:
    "u", "bias", "logSigma", "logSigmaRW", "logitp"
))
