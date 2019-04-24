save_to_database <- function(data, database_name, table_name) {
  con <- dbConnect(RSQLite::SQLite(), dbname=database_name)
  
  # SQLite can't handle dates, so convert dates to strings.
  sanitised_data <- data.frame(data)
  sanitised_data$Date = as.character(sanitised_data$Date)
  
  dbWriteTable(con, table_name, sanitised_data, overwrite=TRUE)
  dbDisconnect(con)
}

load_from_database <- function(database_name, table_name) {
  con <- dbConnect(RSQLite::SQLite(), dbname=database_name)
  data <- dbReadTable(con, table_name)
  dbDisconnect(con)
  # SQLite can't handle dates, so convert to dates from strings.
  data$Date = as.Date(data$Date)
  return(data)
}