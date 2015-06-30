## Code for the Tessera tutorial housing example

# Load necessary libraries
library(datadr)
library(trelliscope)
library(housingData)

# housing data frame is in the housingData package
housingDdf <- ddf(housing)

## Divided data frames (ddf) and divided data objects (ddo)

# Divide the housing data set by the variables "county" and "state"
byCounty <- divide(housingDdf, 
    by = c("county", "state"), update = TRUE)

# Exercise: try the `divide` function


# Data divisions can be accessed by index or by key name

byCounty[[1]]

byCounty[["county=Benton County|state=WA"]]

# Try these ddf functions 

summary(byCounty)
names(byCounty)
length(byCounty)
getKeys(byCounty)


## Transformations

# Function to calculate a linear model and extract 
# the slope parameter
lmCoef <- function(x) {
   coef(lm(medListPriceSqft ~ time, data = x))[2]
}

# Best practice tip: test transformation 
# function on one division 
lmCoef(byCounty[[1]]$value)

# Apply the transform function to the ddf
byCountySlope <- addTransform(byCounty, lmCoef)

# look at one division
byCountySlope[[1]]


# Exercise: create a transformation function
# Hint: the input to your function will be one value from a key/value pair (e.g. `byCounty[[1]]$value`)

transformFn <- function(x) {
    ## you fill in here
}
# test:
transformFn(byCounty[[1]]$value)

# apply:
xformedData <- addTransform(byCounty, transformFn)


## Recombination

countySlopes <- recombine(byCountySlope, 
    combine=combRbind)

head(countySlopes)


# Exercise: Divide two new datasets `geoCounty` and `wikiCounty` by county and state

# look at the data first
head(geoCounty)
head(wikiCounty)

# use divide function on each


## Data operations: drJoin

Join together multiple data objects based on key

```{r rresults='hide', message=FALSE}
joinedData <- drJoin(housing=byCounty, 
    slope=byCountySlope, 
    geo=geoByCounty, 
    wiki=wikiByCounty)
```

## Distributed data objects vs distributed data frames

# Note joinedData is a distributed data object (ddo)
class(joinedData)

# Look at the structure of a ddo value (list rather than data.frame)
joinedData[[176]]


## Data operations: drFilter

# Note that a few county/state combinations do not have housing sales data:
names(joinedData[[2884]]$value)

# We want to filter those out those
joinedData <- drFilter(joinedData, 
    function(v) {
        !is.null(v$housing)
    })

    
## Exercise: Apply one or more of these data operations to 
## `joinedData` or a `ddo` or `ddf` you created:
## drJoin, drFilter, drSample, drSubset, drLapply


## Trelliscope 

# Panel function: plot medListPriceSqft and medSoldPriceSqft by time
timePanel <- function(x) {
   xyplot(medListPriceSqft + medSoldPriceSqft ~ time,
      data = x$housing, auto.key = TRUE, 
      ylab = "Price / Sq. Ft.")
}

# test the panel function on one division
timePanel(joinedData[[176]]$value)

# Create a vdb (visualization database)
vdbConn("housing_vdb", autoYes=TRUE)

# Make a trelliscope display
makeDisplay(joinedData,
   name = "list_sold_vs_time_datadr",
   desc = "List and sold price over time",
   panelFn = timePanel, 
   width = 400, height = 400, 
   lims = list(x = "same")
)

# Launch the Trelliscope viewer
view()


# Exercise: create a panel function
newPanelFn <- function(x) {
   # fill in here
}

# test the panel function
timePanel(joinedData[[1]]$value)

vdbConn("housing_vdb", autoYes=TRUE)

makeDisplay(joinedData,
   name = "panel_test",
   desc = "Your test panel function",
   panelFn = newPaneFn)


# Cognostics function
priceCog <- function(x) { 
   st <- getSplitVar(x, "state")
   ct <- getSplitVar(x, "county")
   zillowString <- gsub(" ", "-", paste(ct, st))
   list(
      slope = cog(x$slope, desc = "list price slope"),
      meanList = cogMean(x$housing$medListPriceSqft),
      meanSold = cogMean(x$housing$medSoldPriceSqft),
      lat = cog(x$geo$lat, desc = "county latitude"),
      lon = cog(x$geo$lon, desc = "county longitude"),
      wikiHref = cogHref(x$wiki$href, desc="wiki link"),
      zillowHref = cogHref(
          sprintf("http://www.zillow.com/homes/%s_rb/", 
              zillowString), 
          desc="zillow link")
   )
}

# Use the cognostics function in trelliscope
makeDisplay(joinedData,
   name = "list_sold_vs_time_datadr2",
   desc = "List and sold price with cognostics",
   panelFn = timePanel, 
   cogFn = priceCog,
   width = 400, height = 400, 
   lims = list(x = "same")
)

view()

# Exercise: create a cognostics function

newCogFn <- function(x) {
#     fill in here
#     list(
#         name1=cog(value1, desc="description")
#     )
}

# test the cognostics function
newCogFn(joinedData[[1]]$value)

# make a new display with your cognostics function
makeDisplay(joinedData,
   name = "cognostics_test",
   desc = "Test panel and cognostics function",
   panelFn = newPaneFn,
   cogFn = newCogFn)
view()