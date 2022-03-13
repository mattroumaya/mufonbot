library(dplyr)
library(rvest)

# this url that contained media is now blocked:
# - "https://mufoncms.com/cgi-bin/report_handler.pl?req=latest_reports"

urls <- c(
  "https://mufoncms.com/last_20_report.html",
  "https://mufoncms.com/last_20_report_public.html"
)


scrape_mufon <- function(url) {
  # scrape data
  data <- read_html(
    url
  ) %>%
    html_element(
      "table"
    ) %>%
    rvest::html_table() %>%
    dplyr::bind_rows()

  names(data) <- paste(data[1, ], sep = "")
  data <- data[-1, ]
  data[["Long Description"]] <- NULL

  return(data)

}

mufon <- purrr::map_df(urls, ~scrape_mufon(.))


write.csv(
  mufon,
  file = paste0("data_raw/data_", make.names(Sys.time()), ".csv"),
  row.names = FALSE
)


