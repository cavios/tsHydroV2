#' Summary of output
#'
#' This function presents a summary of the output
#' @param object An object of class "tsHydro"
#' @param ... Unused, for S3 consistency with [summary()].
#' @return Summary of output
#' @export
summary.tsHydro <- function(object, ...) {
    npar    <- length(object$opt$par)
    logLik  <- object$opt$objective
    conv    <- object$opt$convergence == 0
    mypar   <- as.numeric(exp(object$opt$par))
    parnames <- sub("log", "", names(object$opt$par))

    cat("\n-------------------------\n")
    cat("Summary for get.TS\n")
    cat("-------------------------\n")
    cat(paste(ifelse(conv, "Converged", "Not converged"),
              "with a negative log likelihood of", round(logLik, 3), "\n\n"))
    cat(paste("Number of parameters:", npar, "\n\n"))
    for (i in seq_along(mypar)) {
        cat(paste("Par", i, ":", parnames[i], " = ", round(mypar[i], 3), "\n\n"))
    }
}
