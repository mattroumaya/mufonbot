library(dplyr)
library(rvest)

# scrape data
mufon <- read_html(
  "https://mufoncms.com/cgi-bin/report_handler.pl?req=latest_reports"
) %>%
  html_element(
    "table"
  ) %>%
  rvest::html_table() %>%
  dplyr::bind_rows()

# rename the columns
names(mufon) <- paste(mufon[1, ], sep = "")
mufon <- mufon[-1, ]
mufon$`Long Description` <- NULL

write.csv(
  mufon,
  file = paste0("data_raw/data_", make.names(Sys.Date()), ".csv"),
  row.names = FALSE
)


