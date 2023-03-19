library(tidyverse)
library(rvest)
library(XML)

# scrape NUFORC posting by date: https://www.nuforc.org/webreports/ndxpost.html
url <- c("https://nuforc.org/webreports/ndxp230306.html")

scrape_nuforc <- function(url) {
  base <- rvest::read_html(url) %>%
    XML::htmlParse()

  table <- base %>%
    xpathSApply("//tbody") %>%
    map_df(~ readHTMLTable(., header = F))

  links <- base %>% XML::getHTMLLinks()

  links <- links[links != "https://www.nuforc.org"]
  links <- paste0("https://www.nuforc.org/webreports/", links)

  table <- bind_cols(table, links)
  names(table) <- c("Date/Time", "City", "State", "Country", "Shape", "Duration", "Summary", "Posted", "Image", "URL")

  table <- table %>%
    mutate(ID = paste0(row_number(), make.names(Sys.time())))
  return(table)
}

all <- scrape_nuforc(url)

all_clean <- all %>%
  mutate(madar = stringr::str_detect(Summary, "MADAR")) %>%
  filter(madar == F)

write.csv(all_clean, file = here::here("nuforc", "data_raw", "march_2023.csv"), row.names = F)

## combine old versions
march_april <- read.csv("nuforc/data_raw/march_april_2022.csv")
may <- read.csv("nuforc/data_raw/may_2022.csv")
june <- read.csv("nuforc/data_raw/june_2022.csv")
september <- read.csv("nuforc/data_raw/september_2022.csv")
november <- read.csv("nuforc/data_raw/november_2022.csv")
jan_23 <- read.csv("nuforc/data_raw/january_2023.csv")
march_23 <- read.csv("nuforc/data_raw/march_2023.csv")
all <- bind_rows(march_april, may, june, september, november, jan_23, march_23)

write.csv(all, file = here::here("nuforc", "recent.csv"), row.names = F)
