# This provides a function to load a .pre file. 
# It parses the header to extract meta-data, 
# and returns a data.frame in the following format:
#   [Xref, Yref, Value, Date]
# Xref  : The x coordinate in the grid reference
# Yref  : The y coordinate in the grid reference
# Value : The amount of precipitation in millimeters
# Date  : The first of the month for that month's data.

COLUMN_NAMES <- c("Xref", "Yref", "Value", "Date")

extract_header <- function(textfile_lines, header_linesize) {
  header_text <- paste(head(textfile_lines, header_linesize), sep="\n", collapse='')
  
  # Extract Relevant Info
  years           <- as.integer(strapplyc(header_text, 
                                          "\\[Years=(\\d+)\\-(\\d+)\\]", 
                                          simplify=TRUE))
  latitude_range  <- as.numeric(strapplyc(header_text, 
                                          "\\[Lati=\\s*(\\-?\\d+(?:\\.\\d+)?),\\s*(\\-?\\d+(?:\\.\\d+)?)\\]", 
                                          simplify=TRUE))
  longitude_range <- as.numeric(strapplyc(header_text, 
                                          "\\[Long=\\s*(\\-?\\d+(?:\\.\\d+)?),\\s*(\\-?\\d+(?:\\.\\d+)?)\\]", 
                                          simplify=TRUE))
  grid_coords     <- as.numeric(strapplyc(header_text, 
                                          "\\[Grid X,Y=\\s*(\\-?\\d+),\\s*(\\-?\\d+)\\]", 
                                          simplify=TRUE))
  
  creation_info   <- strapplyc(header_text,
                               "created\\s+on\\s+([\\d\\.]+)\\s+at\\s*([\\d:]+)\\s+by\\s+([\\w\\s\\.]+).pre",
                               simplify=TRUE)
  
  creation_datetime = as.chron(paste(creation_info[1], creation_info[2]),
                               format = c("%d.%m.%Y", "%H:%M"))
  creation_author = creation_info[3]
  
  
  header_obj <- list(years      = years, 
                     longitudes = longitude_range, 
                     latitudes  = latitude_range, 
                     grid       = grid_coords,
                     author     = creation_author,
                     creation   = creation_datetime)
  
  return(header_obj)
}

load_rainfall_data <- function(filename, header_size=5) {
  file_lines <- readLines(filename, n=-1)
  
  header <- extract_header(file_lines, header_size)
  data   <- tail(file_lines, -header_size)
  
  year_count <- diff(header$years) + 1
  
  # Capture grid references.
  grid_references <- data[seq(1, length(data), year_count+1)]
  grid_references <- as.integer(unlist(strapplyc(grid_references, "Grid\\-ref\\=\\s*(\\d+),\\s*(\\d+)", simplify=TRUE)))
  grid_references <- t(matrix(grid_references, nrow=2))
  
  # Remove grid reference rows.
  data <- data[-seq(1, length(data), year_count+1)]
  
  # Split into monthly values
  data <- unlist(strsplit(data, split=" "))
  data <- as.integer(data[data != ""])
  
  # Create dates for values
  date_months <- seq_along(data) %% 12
  date_years  <- header$years[1] + (floor((seq_along(data)-1) / 12)) %% year_count
  date_months[date_months == 0] <- 12
  dates <- as.Date(paste(date_years, date_months, "1", sep='-'))
  
  # Combine grid references and precipitation values
  table <- cbind(grid_references[ceiling(seq_along(data)/(year_count * 12)),], data, deparse.level = 0)
  table <- data.frame(table, dates)
  colnames(table) <- COLUMN_NAMES
  
  comment(table) <- "Precipitation Data. "
  attr(table, "meta") <- header
  
  return(table)
}