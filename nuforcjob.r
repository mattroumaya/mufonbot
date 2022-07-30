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

alt_text <- paste0("Contact @mufonbot for an accurate alt text description. ID = ", df$ID)

# create token
token <- rtweet::rtweet_bot(
  api_key = Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  api_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token = Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret = Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)



if (!is.na(reports$Image)) {
  temp_file <- tempfile(fileext = ".jpeg")
  imgsrc <- rvest::read_html(reports$URL) %>%
    rvest::html_node(xpath = '//*/img') %>%
    rvest::html_attr('src')
  download.file(imgsrc, temp_file)
  rtweet::post_tweet(
    status = tweet,
    media = temp_file,
    media_alt_text = alt_text,
    token = token
  )
} else {
  rtweet::post_tweet(
    status = tweet,
    media_alt_text = alt_text,
    token = token
  )
}

