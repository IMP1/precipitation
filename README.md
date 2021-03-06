# Precipitation Data Code Challenge

This repository is for the [JBA code challenge](https://jbasoftware.com/careers/code-challenge/). The challenge is to load some data on precipitation over time.

The data can be found on the JBA code challenge page, and the file was named `cru-ts-2-10.1991-2000-cutdown.pre`, but this filename is passed as a parameter to the main function, and so can be different.

Running this R Code was done in [RStudio](https://www.rstudio.com/), after setting the working directory as the directory of the repository.

R is a statistical language, and is used to analyse data. Loading the data into R allows it to be visualised, and analysed, with very little additional effort.

The code loads the data, assigning the relevant information in the first lines of the file to a header, and the remaining data into a dataframe.

There is functionality for saving to, and loading from, a database. This example uses a local SQLite file as its database, but converting this to another database only requires changing the `save_to_database` and `load_from_database` functions.

Upon plotting the average precipitation for the sector over time, the values in the graph were much larger than expected. Upon inspection of the data, R returned certain large values for precipitation of `262413385`, `195310665`, `241711854`, `239310874`, `466810104`. I could also get the dates and Xref and Yref for these values and so, looking at the original data file, it seems like these values are a formatting error, and that there should be a space somewhere to split these into two numbers. But is it unclear where the space should be, or whether the middle digit of 1 should instead be a space.

Based off the assumption that these values should be split before the middle '1' digit (as splitting before results in some numbers with a leading 0, which doesn't feature elsewhere), the data looks much more sensible, but I'll need confirmation that this formatting mistake has happened.

If more data were provided for missing grid references, a clearer picture could be obtained of coordintes that have undergone more drastic changes.
