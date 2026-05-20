library(tsHydroV2)
data(namco)

fit <- get.TS(namco)

png("man/figures/namco_fit.png", width = 1000, height = 600, res = 120)
op <- par(mar = c(4, 4, 2, 1))
plot(fit, addError = TRUE, col = "blue", main = "Nam Co — fitted water level")
par(op)
dev.off()

summary(fit)
export.tsHydro(fit, file = "namco_ts.dat", exportPar = TRUE)
