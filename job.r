library(dplyr)
library(rvest)

# this url that contained media is now blocked:
# - "https://mufoncms.com/cgi-bin/report_handler.pl?req=latest_reports"

# scrape data
mufon <- read_html(
  "https://mufoncms.com/last_20_report.html"
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
  file = paste0("data_raw/data_", make.names(Sys.time()), ".csv"),
  row.names = FALSE
)


