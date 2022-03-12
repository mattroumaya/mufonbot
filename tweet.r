library(glue)
library(dplyr)
library(readr)
library(rtweet)
library(rvest)
library(stringr)

# read in recent data
df <- file.info(list.files("data_raw", full.names = T))
data <- rownames(df)[which.max(df$mtime)]
df <- read_csv(data)

# read in case numbers
cases <- read_csv("data_raw/casenumbers/case numbers.csv")

# filter out cases that were already tweeted
df <- df %>%
  dplyr::group_by_all() %>%
  unique() %>%
  dplyr::ungroup() %>%
  dplyr::filter(!`Case Number` %in% cases$ID) %>%
  dplyr::filter(!is.na(`Short Description`) & !is.na(City) & !is.na(`State/Country`) & `Short Description` != "")

if (nrow(df) > 1) {

  reports <- df %>%
    dplyr::sample_n(1)

  # remove punctuation and create city hashtag
  city_hashtag <- gsub("[[:punct:]]+", "", reports$City)
  city_hashtag <- paste0("#", gsub(" ", "", city_hashtag, fixed = TRUE))

  # check for media
  media_df <- rvest::read_html("https://mufoncms.com/last_20_report.html") %>%
    rvest::html_nodes("a") %>%
    rvest::html_attr("href") %>%
    stringr::str_subset(c("\\.jpg|\\.JPG|\\.PNG|\\.png|\\.jpeg|\\.JPEG")) %>%
    dplyr::as_tibble() %>%
    dplyr::mutate(
      "Case Number" = sub("\\_submitter.*", "", value),
      "Case Number" = as.numeric(sub(".*\\/", "", `Case Number`))
    ) %>%
    dplyr::group_by(`Case Number`) %>%
    dplyr::slice(1) %>%
    dplyr::right_join(reports) %>%
    dplyr::filter(!is.na(value))

  tweet <- reports %>%
    glue::glue_data(
      "Event: {`Short Description`}",


      "

      Location: {City}, {`State/Country`}",


      "

      Date of Event: {`Date of Event`}",


      "

      #ufotwitter #uaptwitter {city_hashtag}"
    )

  # archive case number
  case_numbers <- read_csv("data_raw/casenumbers/case numbers.csv")

  # append recent tweet
  case_numbers <- case_numbers %>%
    dplyr::add_row(ID = reports$`Case Number`)

  # update case number so it doesn't repeat
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

  if (nrow(media_df) > 0) {
    # if media exists, download and make available
    temp_file <- tempfile()
    download.file(media_df$value, temp_file)
    rtweet::post_tweet(
      status = tweet,
      media = temp_file,
      token = token
    )
  }

  if (nrow(media_df) == 0) {
    rtweet::post_tweet(
      status = tweet,
      token = token
    )
  }
}
