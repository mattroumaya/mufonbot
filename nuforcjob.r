library(glue)
library(rvest)
library(dplyr)
library(readr)
library(rtweet)
library(stringr)
library(here)

df <- read_csv("nuforc/recent.csv") %>%
  rename("Date/Time" = Date.Time)

# read archive of cases to prevent double-posting
cases <- read_csv(here::here("nuforc", "data_raw", "archive.csv"))

# filter out cases that were already tweeted
df <- df %>%
  dplyr::group_by_all() %>%
  unique() %>%
  dplyr::ungroup() %>%
  dplyr::filter(!ID %in% cases$id)

reports <- df %>%
  dplyr::sample_n(1)

# append recent tweet
case_numbers <- cases %>%
  dplyr::add_row(id = reports$ID)

city_hashtag <- gsub("[[:punct:]]+", "", reports$City)
city_hashtag <- paste0("#", gsub(" ", "", city_hashtag, fixed = TRUE))


tweet <- reports %>%
  glue::glue_data(
    "Summary: {`Summary`}",


    "

    Location: {City}, {State}, {Country}",


    "

    Date of Event: {`Date/Time`}",


    "

    #ufotwitter #uaptwitter {city_hashtag}"
  )


# update case number so it doesn't repeat
write.csv(case_numbers, here::here("nuforc", "data_raw", "archive.csv"), row.names = F)

# create token
token <- rtweet::create_token(
  app = "mufonbot",
  consumer_key = Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token = Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret = Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET"),
  set_renv = FALSE
)

if (!is.na(reports$Image)) {
  temp_file <- tempfile()
  imgsrc <- rvest::read_html(reports$URL) %>%
    rvest::html_node(xpath = '//*/img') %>%
    rvest::html_attr('src')
  download.file(imgsrc, temp_file)
  rtweet::post_tweet(
    status = tweet,
    media = temp_file,
    token = token
  )
} else {
  rtweet::post_tweet(
    status = tweet,
    token = token
  )
}
