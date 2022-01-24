library(dplyr)
library(rvest)

# scrape data
mufon <- read_html(
  "https://mufoncms.com/cgi-bin/report_handler.pl?req=latest_reports"
) %>%
  html_element(
    "table"
  )

if (length(mufon)>0) {
mufon <- mufon %>%
  rvest::html_table() %>%
  dplyr::bind_rows()
} else {

# site above contains links to media and has been glitching out since 1/23/22
# for now, just pull text reports

  mufon <- read_html(
    "https://mufoncms.com/last_20_report_public.html"
  ) %>%
    html_element(
      "table"
    ) %>%
    rvest::html_table() %>%
    dplyr::bind_rows()
}


# rename the columns
names(mufon) <- paste(mufon[1, ], sep = "")
mufon <- mufon[-1, ]
mufon$`Long Description` <- NULL

write.csv(
  mufon,
  file = paste0("data_raw/data_", make.names(Sys.time()), ".csv"),
  row.names = FALSE
)


