library(gsubfn)
library(DBI)
library(chron)

source("db_access.r")
source("load_pre.r")

DATABASE_NAME <- "example_db.sqlite"
TABLE_NAME    <- "precipitation"
FILENAME      <- "cru-ts-2-10.1991-2000-cutdown.pre"

filepath <- paste(getwd(), FILENAME, sep="/")

rainfall_data <- load_rainfall_data(filepath)

# Save to and Load from a Database
#save_to_database(rainfall_data, DATABASE_NAME, TABLE_NAME)
#rainfall_data <- load_from_database(DATABASE_NAME, TABLE_NAME)

# Get average rainfall for sector over time.
average_sector_rainfall_over_time = aggregate(rainfall_data, 
                                              by=list(rainfall_data$Date),
                                              FUN = mean)

plot(average_sector_rainfall_over_time$Date, 
     average_sector_rainfall_over_time$Value,
     type="l",
     main="Average Precipitation Over Time for Sector",
     xlab="Date",
     ylab="Precipitation (mm)")

# Get increases for each grid reference within sector
sector_increases <- aggregate(rainfall_data,
                             by=list(rainfall_data$Xref, rainfall_data$Yref),
                             FUN=range)
sector_increases <- as.matrix(xtabs(Value ~ Xref + Yref,
                                    data=sector_increases, sparse=TRUE))

colour_palette  <- c("black", 
                     colorRampPalette(c("yellow", "orange", "red"))
                     (n=max(sector_increases)))
heatmap(sector_increases, col=colour_palette, scale="none")


# Find anomalous data bringing averages up.
print(rainfall_data[rainfall_data$Value >= 10000,])
