library(gsubfn)
library(DBI)

TABLE_NAME = "precipitation"
COLUMN_NAMES = c("Xref", "Yref", "Value", "Date")

extract_header <- function(textfile_lines, header_linesize) {
  header_text <- paste(head(textfile_lines, header_linesize), sep="\n", collapse='')
  
  years           <- as.integer(strapplyc(header_text, 
                                          "\\[Years=(\\d+)\\-(\\d+)\\]", 
                                          simplify = TRUE))
  latitude_range  <- as.numeric(strapplyc(header_text, 
                                          "\\[Lati=\\s*(\\-?\\d+(?:\\.\\d+)?),\\s*(\\-?\\d+(?:\\.\\d+)?)\\]", 
                                          simplify = TRUE))
  longitude_range <- as.numeric(strapplyc(header_text, 
                                          "\\[Long=\\s*(\\-?\\d+(?:\\.\\d+)?),\\s*(\\-?\\d+(?:\\.\\d+)?)\\]", 
                                          simplify = TRUE))
  grid_coords     <- as.numeric(strapplyc(header_text, 
                                          "\\[Grid X,Y=\\s*(\\-?\\d+),\\s*(\\-?\\d+)\\]", 
                                          simplify = TRUE))
  
  header_obj <- list(years=years, longitudes=longitude_range, 
                 latitudes=latitude_range, grid=grid_coords)
  class(header_obj) <- "precipitation_header"
  return(header_obj)
}

load_rainfall_data <- function(filename, header_size=5) {
  file_lines <- readLines(filename, n=-1)
  
  header <- extract_header(file_lines, header_size)
  data   <- tail(file_lines, -header_size)

  year_count <- diff(header$years) + 1

  # Capture grid references.
  grid_references <- data[seq(1, length(data), year_count+1)]
  grid_references <- as.integer(unlist(strapplyc(grid_references, "Grid\\-ref\\=\\s*(\\d+),\\s*(\\d+)", simplify = TRUE)))
  grid_references <- t(matrix(grid_references, nrow=2))

  # Remove grid reference rows.
  data <- data[-seq(1, length(data), year_count+1)]
  
  # Split into monthly values
  data <- unlist(strsplit(data, split=" "))
  data <- as.integer(data[data != ""])
  
  # Create dates for values
  date_months <- seq_along(data) %% 12
  date_years  <- header$years[1] + floor((seq_along(data)-1) / 12)
  date_months[date_months == 0] <- 12
  dates <- as.Date(paste(date_years, date_months, "1", sep='-'))
  

  # Combine grid references and precipitation values
  table <- cbind(grid_references[ceiling(seq_along(data)/(year_count * 12)),], data, deparse.level = 0)
  table <- data.frame(table, dates)
  colnames(table) <- COLUMN_NAMES
  
  return(table)
}

save_to_database <- function(data) {
  con <- dbConnect(RSQLite::SQLite(), dbname="example_db.sqlite")
  dbWriteTable(con, TABLE_NAME, data)
  dbDisconnect(con)
}

load_from_database <- function() {
  con <- dbConnect(RSQLite::SQLite(), dbname="example_db.sqlite")
  data <- dbReadTable(con, TABLE_NAME)
  dbDisconnect(con)
  return(data)
}

filename <- paste(getwd(), "cru-ts-2-10.1991-2000-cutdown.pre", sep="/")
rainfall_data <- load_rainfall_data(filename)
save_to_database(rainfall_data)
saved_data <- load_from_database()