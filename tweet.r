library(glue)
library(dplyr)
library(readr)
library(rtweet)

# read in recent data

df <- file.info(list.files("data_raw", full.names = T))
data <- rownames(df)[which.max(df$mtime)]
df <- read_csv(data)

# read in case numbers
cases <- read_csv("data_raw/casenumbers/case numbers.csv")

# filter out cases that were already tweeted
df <- df %>%
  dplyr::filter(!`Case Number` %in% cases$ID)



reports <- df %>%
  dplyr::sample_n(1)

tweet <- reports %>%
  glue::glue_data("Event: {`Short Description`}",

                  "

                  Location: {City}, {`State/Country`}",

                  "

                  Date of Event: {`Date of Event`}",

                  "

                  #ufotwitter")

# archive case number
case_numbers <- dplyr::tibble(
  ID = 0
)

# append recent tweet
case_numbers <- case_numbers %>%
  dplyr::add_row(ID = reports$`Case Number`)

# update case number so it does not repeat
write.csv(case_numbers, "data_raw/casenumbers/case numbers.csv", row.names = F)


# create token
token <- rtweet::create_token(
  app = "mufonbot",
  consumer_key = Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token = Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret = Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET"),
  set_renv = FALSE
)


# create token
token <- rtweet::create_token(
  app = "mufonbot",
  consumer_key = api_key,
  consumer_secret = api_key_secret,
  access_token = access_token_x,
  access_secret = access_token_secret_x,
  set_renv = FALSE
)


# send tweet
rtweet::post_tweet(
  status = tweet,
  token = token
)
