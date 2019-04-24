library(gsubfn)
library(DBI)
library(chron)

source("db_access.r")
source("load_pre.r")

DATABASE_NAME <- "example_db.sqlite"
TABLE_NAME    <- "precipitation"
FILENAME <- "cru-ts-2-10.1991-2000-cutdown.pre"

filepath <- paste(getwd(), FILENAME, sep="/")

rainfall_data <- load_rainfall_data(filepath)
save_to_database(rainfall_data, DATABASE_NAME, TABLE_NAME)
rainfall_data <- load_from_database(DATABASE_NAME, TABLE_NAME)

average_sector_rainfall_over_time = aggregate(rainfall_data, 
                                              by=list(rainfall_data$Date),
                                              FUN = mean)

sector_increases = aggregate(rainfall_data,
                             by=list(rainfall_data$Xref, rainfall_data$Yref),
                             FUN=mean)

# Find anomolous data bringing averages up.
print(rainfall_data[rainfall_data$Value >= 10000, ])

plot(average_sector_rainfall_over_time$Date, 
     average_sector_rainfall_over_time$Value,
     type="l",
     main="Average Precipitation Over Time for Sector",
     xlab="Date",
     ylab="Precipitation (mm)")

