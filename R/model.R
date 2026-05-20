## Negative log-likelihood for the tsHydro state-space model, ported from
## tsHydro/src/tsHydro.cpp to RTMB.
##
## Returns a closure suitable for RTMB::MakeADFun(parms, nll).

tsHydro_nll <- function(data) {

    force(data)

    function(parms) {
        RTMB::getAll(data, parms)

        ## RTMB operator overloads — required for AD dispatch on c() and [<-
        ## once the package is byte-compiled.
        "c"   <- RTMB::ADoverload("c")
        "[<-" <- RTMB::ADoverload("[<-")

        dt1 <- function(x) 1 / pi / (1 + x * x)
        ilogit <- function(x) 1 / (1 + exp(-x))
        nldens <- function(x, mu, sd, p) {
            z <- (x - mu) / sd
            -log(1 / sd * ((1 - p) * RTMB::dnorm(z, 0, 1, FALSE) + p * dt1(z)))
        }

        timeSteps <- length(times)
        nobs <- length(height)
        noTracks <- nrow(trackinfo)

        biasvec <- c(0, bias)

        p <- ilogit(logitp)
        ans <- 0

        if (length(priorHeight) == 1) {
            ans <- ans - sum(RTMB::dnorm(u, priorHeight[1], priorSd[1], TRUE))
        }

        sdRW <- exp(logSigmaRW)
        dts <- diff(times)
        u_prev <- u[1:(timeSteps - 1L)]
        u_curr <- u[2:timeSteps]
        ans <- ans - sum(RTMB::dnorm(u_curr, u_prev, sdRW * sqrt(dts), TRUE))

        sdObs <- exp(logSigma)

        ## Each track contributes its first observation's time index to every
        ## observation in that track (matches the C++: timeidx(trackinfo(t,0))).
        obsTimeIdx <- integer(nobs)
        for (t in seq_len(noTracks)) {
            from <- trackinfo[t, 1] + 1L
            n <- trackinfo[t, 3]
            obsTimeIdx[from:(from + n - 1L)] <- timeidx[from]
        }

        mu <- u[obsTimeIdx] + biasvec[satid + 1L]

        ## Mirrors the C++ exactly: the second assignment unconditionally
        ## overwrites the first, so varPerTrack alone falls back to satid.
        idxVar <- if (varPerTrack == 1L) trackidx + 1L else satid + 1L
        idxVar <- if (varPerQuality == 1L) qfid + 1L else satid + 1L

        obsSd <- sdObs[idxVar] / sqrt(weights)

        if (length(priorHeight) != 1) {
            hsdMask <- !is.na(hsd)
            if (any(hsdMask)) {
                obsSd[hsdMask] <- hsd[hsdMask] / sqrt(weights[hsdMask])
            }
        }

        if (length(priorHeight) == 1) {
            keep <- (height > (priorHeight[1] - 5 * priorSd[1])) &
                    (height < (priorHeight[1] + 5 * priorSd[1]))
            ans <- ans + sum(nldens(height[keep], mu[keep], obsSd[keep], p))
        } else {
            ans <- ans + sum(nldens(height, mu, obsSd, p))
        }

        pred <- mu

        aveH <- sum(u) / length(u)
        RTMB::ADREPORT(aveH)

        if (length(group) > 0) {
            ngroup <- max(group) + 1L
            ## Sparse aggregation via incidence matrix — keeps the AD tape clean.
            M <- matrix(0, nrow = ngroup, ncol = length(newtimeidx))
            for (i in seq_along(newtimeidx)) M[group[i] + 1L, i] <- 1
            groupN <- rowSums(M)
            groupAve <- as.vector(M %*% u[newtimeidx]) / groupN
            RTMB::ADREPORT(groupAve)
        }

        RTMB::REPORT(pred)
        ans
    }
}
