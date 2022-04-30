library(tidyverse)
library(rvest)
library(XML)

# scrape NUFORC posting by date: https://www.nuforc.org/webreports/ndxpost.html

# URLs below are for 03/04/2022 and 04/22/2022
urls <- c("https://www.nuforc.org/webreports/ndxp220422.html",
          'https://www.nuforc.org/webreports/ndxp220304.html')

scrape_nuforc <- function(url){
  base <- rvest::read_html(url) %>%
    XML::htmlParse()

  table <- base %>%
    xpathSApply("//tbody") %>%
    map_df(~readHTMLTable(., header = F))

  links <- base %>% XML::getHTMLLinks()

  links <- links[links != "https://www.nuforc.org"]
  links <- paste0("https://www.nuforc.org/webreports/", links)

  table <- bind_cols(table, links)
  names(table) <- c("Date/Time", "City", "State", "Country", "Shape", "Duration", "Summary", "Posted", "Image", "URL")

  table <- table %>%
    mutate(ID = paste0(row_number(), make.names(Sys.time())))
  return(table)

}

all <- map_df(urls, ~scrape_nuforc(.))

write.csv(all, file = here::here("nuforc", "data_raw", "march_april_2022.csv"), row.names = F)
