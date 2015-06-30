## session initialization
##---------------------------------------------------------

library(datadr)
library(parallel)
library(trelliscope)

# create a datadr backend with a 3 core cluster
options(defaultLocalDiskControl = localDiskControl(makeCluster(3)))

# set basepath to directory containing taxiOneWeek.csv
basepath <- "__SET_PATH__"

# initialize a vdb connection for trelliscope displays
# the first time you do this it will ask you to confirm
vdbConn(file.path(basepath, "vdb"), autoYes = TRUE)

## read in the data
##---------------------------------------------------------

# first read in a subset to get a feel for the data
test <- read.csv(file.path(basepath, "taxiOneWeek.csv"), nrow = 10,
  stringsAsFactors = FALSE)
str(test)

# build a transformation function that will convert date columns
# and get rid of coordinates outside of NYC
trans <- function(x) {
  require(lubridate)
  x$pickup_datetime <- fast_strptime(x$pickup_datetime, format = "%Y-%m-%d %H:%M:%S", tz = "EST")
  x$dropoff_datetime <- fast_strptime(x$dropoff_datetime, format = "%Y-%m-%d %H:%M:%S", tz = "EST")

  # Set coordinates outside of NYC bounding box to NA to filter outliers.
  nw <- list(lat = 40.917577, lon = -74.259090)
  se <- list(lat = 40.477399, lon = -73.700272)
  ind <- which(x$dropoff_longitude < nw$lon | x$dropoff_longitude > se$lon)
  x$dropoff_longitude[ind] <- NA
  ind <- which(x$pickup_longitude < nw$lon | x$pickup_longitude > se$lon)
  x$pickup_longitude[ind] <- NA
  ind <- which(x$dropoff_latitude < se$lat | x$dropoff_latitude > nw$lat)
  x$dropoff_latitude[ind] <- NA
  ind <- which(x$pickup_latitude < se$lat | x$pickup_latitude > nw$lat)
  x$pickup_latitude[ind] <- NA
  x
}

# test this transformation on a subset and make sure it works
str(trans(test))

# now read the whole file in as a ddf
taxi <- drRead.csv(file.path(basepath, "taxiOneWeek.csv"),
  output = localDiskConn(file.path(basepath, "taxiddf")),
  postTransFn = trans,
  rowsPerBlock = 300000,
  stringsAsFactors = FALSE)

# update the attributes
taxi <- updateAttributes(taxi)

# look at what has been created on disk
list.files(file.path(basepath, "taxiddf"))

# if you need to get taxi back in a future session
# you don't need to read it in again - just reconnect
taxi <- ddf(localDiskConn(file.path(basepath, "taxiddf")))

## summaries
##---------------------------------------------------------

# We can get a feel for the data by looking at the summaries that are already available from calling `updateAttributes()` and also from computing additional summaries.

# look at summary
summary(taxi)

# plot medallion frequency
mft <- summary(taxi)$medallion$freqTable
plot(sort(mft$Freq),
  ylab = "Medallion frequency",
  main = "Frequency of occurrance of medallions for top and bottom 5000")
abline(v = 5000, lty = 2, col = "gray")

## Plot the hack license use frequency
hft <- summary(taxi)$hack_license$freqTable

plot(hft$Freq,
  ylab = "Hack license frequency",
  main ="Frequncy of use for hack licenses for top and bottom 5000")
abline(v = 5000, lty = 2, col = "gray")

## Compute a list of the quantiles of some of the variables
varName <- c("passenger_count",
             "trip_time_in_secs",
             "trip_distance",
             "total_amount",
             "tip_amount")

quantList <- lapply(varName, function(var) drQuantile(taxi, var = var, tails = 1))

## Create and test a function to create the quantile plot
quant.plot <- function(quant, var.name, ylim){
  p1 <- ggplot(quant, aes(fval, q)) +
    geom_point() +
    ggtitle(paste("Quantile plot of", var.name)) +
    ylab(var.name) + xlab("Proportion")
  p2 <- ggplot(subset(quant, q < ylim),
               aes(fval, q)) +
    geom_point() +
    ggtitle(paste("Quantile plot of", var.name)) +
    ylab(var.name) + xlab("Proportion")
  grid.arrange(p1, p2, ncol = 2)
}
require(ggplot2)
require(gridExtra)
quant.plot(quantList[[1]], "passenger_count", 10)

# plot the quantile information, with limits on the y axis.
ylims <- c(10,
           3000,
           25,
           100,
           40)

Map(quant.plot, quantList, varName, ylims)

# drill down on tips by payment type
tip_quant <- drQuantile(taxi, var = "tip_amount", by = "payment_type", tails = 1)

ggplot(subset(tip_quant, q < 20),
       aes(fval, q, group = payment_type)) +
  geom_point(aes(colour = factor(payment_type))) +
  ggtitle(paste("Quantile plot of tip amount")) +
  ylab("Tip amount") + xlab("Proportion")

# create hexbin plot of taxi data.
library(hexbin)
library(trelliscope)

pickup_latlon <- drHexbin(taxi, "pickup_longitude", "pickup_latitude",
  xbins = 300, shape = 1.4)

plot(pickup_latlon, trans = log, inv = exp, style = "centroids",
  xlab = "longitude", ylab = "latitude", legend = FALSE)

# look at the relationship between fare and distance traveled
trns <- function(x) log2(x + 1)
amount_vs_dist <- drHexbin(taxi, "trip_distance", "total_amount",
  xbins = 150, shape = 1, xTransFn = trns, yTransFn = trns)

plot(amount_vs_dist, trans = log, inv = exp,
  style = "colorscale", colramp = LinOCS,
  xlab = "Distance (log2 miles)",
  ylab = "Total Amount Paid (log2 dollars)")

# plot with another color scale
plot(pickup_latlon, trans = log, inv = exp,
  style = "colorscale", colramp = LinOCS,
  xlab = "longitude", ylab = "latitude")

# zooming in on Manhattan
xRange <- c(-74.03, -73.92)
yRange <- c(40.7, 40.82)
tmp <- addTransform(taxi, function(x) {
  subset(x, pickup_longitude < -73.92 & 
           pickup_longitude > -74.03 & 
           pickup_latitude > 40.7 & 
           pickup_latitude < 40.82)
})

pickup_latlon_manhat <- drHexbin(tmp, "pickup_longitude", "pickup_latitude",
                                 xbins = 300, shape = 1.4, xRange = xRange, yRange = yRange)

# plot with different color scales
plot(pickup_latlon_manhat, trans = log, inv = exp,
  style = "centroids", xlab = "longitude", ylab = "latitude", legend = FALSE)
plot(pickup_latlon_manhat, trans = log, inv = exp,
  style = "colorscale", xlab = "longitude", ylab = "latitude", colramp = LinOCS)

## division by distance
##---------------------------------------------------------

# break the data up by an approximation of the distance travelled
# and investigate some properties of the data at different distances.

# use geosphere package to compute 'as-the-crow-flies' distance
library(geosphere)

# define breakpoints for categorizating distance
dist_breaks <- c(seq(0, 1, by = 0.1),
  seq(1.25, 5, by = 0.25), 6:10, 12, 15, 20, 25)

# add transformation that computes distance
taxi_dist <- taxi %>%
  addTransform(function(x) {
    # get log distance in miles between pickup and dropoff
    x$distance <- distHaversine(
      x[,c("pickup_longitude", "pickup_latitude")],
      x[,c("dropoff_longitude", "dropoff_latitude")],
      r = 3963.1676)
    x <- subset(x, !is.na(x$distance))
    # break distance into categories
    x$distance_cat <- cut(x$distance, breaks = dist_breaks,
      include.lowest = TRUE)
    x$distance_index <- cut(x$distance, breaks = dist_breaks,
      include.lowest = TRUE, labels = FALSE)
    x
  })

names(taxi_dist)

# look at the distribution of our new categorical variable
distAgg <- drAggregate(~ distance_cat, data = taxi_dist)
distAgg

# divide the ddf by the distance category and payment type
taxi_by_dist <- divide(taxi_dist,
  by = c("distance_index", "payment_type"),
  output = localDiskConn(file.path(basepath, "taxi_by_dist")),
  update = TRUE,
  overwrite = TRUE)


## investigating Properties by Distance
##---------------------------------------------------------

# look for differences in tip percentages by distance category
# first add a transformation that computes this
meanTipPrct <- function(x)
  mean((x$tip_amount * 100) / x$fare_amount, na.rm = TRUE)
tipPrctByDist <- addTransform(taxi_by_dist, meanTipPrct)

# look at a subset
tipPrctByDist[[8]]$value

# recombine into a data frame
tipPrctByDistComb <- recombine(tipPrctByDist, combine = combRbind)
tipPrctByDistComb

# plot result
xyplot(val ~ distance_index, groups = payment_type,
  data = tipPrctByDistComb,
  auto.key = list(space = "right"),
  aspect = 1.5, type = c("p", "g"))

# now look at tolls paid by distance category
meanToll <- function(x)
  mean(x$tolls_amount, na.rm = TRUE)
meanTollByDist <- addTransform(taxi_by_dist, meanToll)

# look at a subset
meanTollByDist[[8]]$value

# recombine into a data frame
meanTollByDistComb <- recombine(meanTollByDist, combine = combRbind)
meanTollByDistComb

# plot result
xyplot(val ~ distance_index, groups = payment_type,
  data = meanTollByDistComb,
  auto.key = list(space = "right"),
  aspect = 1, type = c("p", "g"))

## trelliscope displays
##---------------------------------------------------------

# create a plot of the total fare vs. distance with toll amount removed
no_toll <- function(x) {
  x$no_toll <- x$total_amount - x$tolls_amount
  x
}

# test the function on a subset
head(no_toll(taxi[[1]]$value))

# add the transformation
taxiNoToll  <- addTransform(taxi, no_toll)

# look at the result
taxiNoToll

# look at the name of the result
names(taxiNoToll)

# look at the relationship between fare without tolls and distance traveled
trns <- function(x) log2(x + 1)
amount_vs_dist <- drHexbin(taxiNoToll, "trip_distance", "no_toll",
  xbins = 150, shape = 1, xTransFn = trns, yTransFn = trns,
  xRange = c(0, 100), yRange = c(0, 650))

plot(amount_vs_dist, trans = log, inv = exp, style = "colorscale",
  colramp = LinOCS, xlab = "Distance (log2 miles)",
  ylab = "Amount Paid Less Tolls (log2 dollars)")

# look at just the fare without tolls or tip
amount_vs_dist <- drHexbin(taxiNoToll, "trip_distance", "fare_amount",
  xbins = 150, shape = 1, xTransFn = trns, yTransFn = trns,
  xRange = c(0, 100), yRange = c(0, 650))

plot(amount_vs_dist, trans = log, inv = exp, style = "colorscale",
  colramp = LinOCS, xlab = "Distance (log2 miles)",
  ylab = "Fare paid, no tip or tolls (log2 dollars)")

# zooming in on Manhattan
xRange <- c(-74.03, -73.92)
yRange <- c(40.7, 40.82)
tmp <- addTransform(taxi, function(x) {
  subset(x, pickup_longitude < -73.92 & pickup_longitude > -74.03 &
  pickup_latitude > 40.7 & pickup_latitude < 40.82)
})

# divide the ddf by the distance-rate_code categories.
taxi_by_dist_code <- divide(taxi_dist, by = c("distance_index", "rate_code"),
  output = localDiskConn(file.path(basepath, "taxi_by_dist_code"), 
                         autoYes = TRUE, reset = TRUE),
  update = TRUE)

names(taxi_by_dist_code)

# a panel function for the data divided by distance and rate code
xRange <- c(-74.03, -73.92)
yRange <- c(40.7, 40.82)
distCodePanel <- function(x) {
  ggplot(x, aes(pickup_longitude, pickup_latitude)) +
    stat_binhex(bins = 300, rm.na = TRUE) +
    xlim(xRange) + ylim(yRange)
}
distCodePanel(taxi_by_dist_code[[1]]$value)

# create a cognositics function
taxiCog <- function(x) {
  list(
    meanFare = cogMean(x$fare_amount),
    meanToll = cogMean(x$tolls_amount),
    meanTipPercent = cogMean((x$tip_amount *100) / x$fare_amount),
    count = nrow(x)
  )
}

makeDisplay(taxi_by_dist_code,
  name = "Lat and Lon of pickup for trips",
  desc = "Lat and Lon of pickup location for trips",
  panelFn = distCodePanel,
  width = 400, height = 400,
  cogFn = taxiCog,
  lims = list(x = "same")
)

# remove trips with cash payments which don't record tips
diskConn <- localDiskConn(file.path(basepath, "taxi_by_dist_code2"), 
                          autoYes = TRUE, reset = TRUE)
taxi_by_dist_code2 <- drLapply(taxi_by_dist_code, function(x) x$payment_type != "CSH",
  combine = combDdo, output = diskConn)
updateAttributes(taxi_by_dist_code2)

# look at tip percentage vs time of the day, distance and code
distCodeTimePanel <- function(x) {
  x$hour <- as.factor(substring(strftime(x$pickup_datetime,
    format = "%Y-%m-%d %H:%M:%S"), 12, 13))
  x$tipPct <- (x$tip_amount * 100) / x$fare_amount
  ggplot(x, aes(hour, tipPct)) +
    geom_boxplot(na.rm = TRUE) + ylim(0, 100)
}

distCodeTimePanel(taxi_by_dist_code[[8]]$value)

makeDisplay(taxi_by_dist_code,
  name = "Tip percent by time of day",
  desc = "Tip percent by time of day",
  panelFn = distCodeTimePanel,
  width = 400, height = 400,
  cogFn = taxiCog)

