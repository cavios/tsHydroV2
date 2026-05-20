#' Simple print  of output
#'
#' This function presents a summary of the output
#' @param x An object of class "tsHydro"
#' @param ... Unused, for S3 consistency with [print()].
#' @return Print the objective function and state convergence
#' @export
print.tsHydro <- function(x, ...) {
    cat("tsHydro fit: negative log likelihood is", x$opt$objective,
        "Convergence", ifelse(x$opt$convergence == 0, "OK", "failed"), "\n ")
}
