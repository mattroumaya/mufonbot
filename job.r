library(dplyr)
library(rvest)

# scrape data
mufon <- rvest::read_html(
  'https://mufoncms.com/last_20_report_public.html'
) %>%
  rvest::html_element("table") %>%
  rvest::html_table() %>%
  dplyr::bind_rows()

# rename the columns
names(mufon) <- paste(mufon[1, ], sep = "")
mufon <- mufon[-1,]

write.csv(mufon, file = paste0("data_raw/data_", make.names(Sys.time()), ".csv"), row.names = FALSE)
