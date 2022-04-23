library(dplyr)
library(rvest)

# this url that contained media is now blocked:
# - "https://mufoncms.com/cgi-bin/report_handler.pl?req=latest_reports"

scrape_mufon <- function(url) {
  # scrape data
  data <- read_html(url) %>%
    html_element("table") %>%
    rvest::html_table() %>%
    dplyr::bind_rows()

  names(data) <- paste(data[1, ], sep = "")
  data <- data[-1, ]
  data[["Long Description"]] <- NULL
  data <- data %>%
    filter(`Short Description` != "")

  return(data)
}

mufon <- scrape_mufon("https://mufoncms.com/last_20_report_public.html")

write.csv(mufon, file = paste0("data_raw/data_", make.names(Sys.time()), ".csv"), row.names = FALSE)


