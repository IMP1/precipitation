library(gsubfn)

column_names = c("Xref", "Yref", "Date", "Value")
first_month  = 1 # First column is January.

load_rainfall_data <- function(filename, header_size=5) {
  file_lines <- readLines(filename, n=-1)
  
  header <- paste(head(file_lines, header_size), sep="\n", collapse='')
  data   <- tail(file_lines, -header_size)
  
  years      <- as.integer(strapplyc(header, "\\[Years=(\\d+)\\-(\\d+)\\]", simplify = TRUE))
  year_count <- diff(years) + 1

  # Capture grid references.
  grid_references <- data[seq(1, length(data), year_count+1)]
  grid_references <- as.integer(unlist(strapplyc(grid_references, "Grid\\-ref\\=\\s*(\\d+),\\s*(\\d+)", simplify = TRUE)))
  grid_references <- t(matrix(grid_references, nrow=2))
  
  # Remove grid reference rows.
  data <- data[-seq(1, length(data), year_count+1)]
  
  # Split into monthly values
  data <- unlist(strsplit(data, split=" "))
  data <- as.integer(data[data != ""])
  
  table <- data
  
  print(data[1:12])
  print(table[1:12])
  
  foo <- cbind(grid_references[ceiling(seq_along(data)/(year_count * 12)),], data, deparse.level = 0)
  print(foo[115:124,])

  # strlist = strsplit(strvec, split="Grid-ref=")  
  # # changing to matrix (works only if the structure of each line is the same)
  # strmat = do.call(rbind, strlist)
  # # lets take only numbers
  # df = strmat[ ,c(2,4,6)]
  # # defining the names
  # colnames(df) = strmat[1 ,c(1,3,5)]
  # # changing strings to numerics (might be better methods, have any suggestions?)
  # df = apply(df, 2, as.numeric)
  # # changing to data.frame
  # df = as.data.frame(df)
  # # now you can do that ever you want
  # plot(df$simulation_time, type="l")
  return(header)
}

path <- getwd()
filename = paste(path, "cru-ts-2-10.1991-2000-cutdown.pre", sep="/")
railfall_data = load_rainfall_data(filename)

