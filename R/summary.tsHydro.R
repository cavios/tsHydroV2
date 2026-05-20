#' Summary of output
#'
#' This function presents a summary of the output
#' @param x An object of class "tsHydro"
#' @return Summary of output
#' @export
summary.tsHydro <- function(x) {
    npar    <- length(x$opt$par)
    logLik  <- x$opt$objective
    conv    <- x$opt$convergence == 0
    mypar   <- as.numeric(exp(x$opt$par))
    parnames <- sub("log", "", names(x$opt$par))

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
