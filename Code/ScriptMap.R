# Load the necessary package
library(readr)
library(text)
library(googleLanguageR)

# Install text required python packages in a conda environment (with defaults).
textrpp_install()

# Initialize the installed conda environment.
# save_profile = TRUE saves the settings so that you don't have to run textrpp_initialize() after restarting R. 
textrpp_initialize(save_profile = TRUE)


# Set your Google Cloud Translation API key
Sys.setenv(GOOGLE_APPLICATION_CREDENTIALS = file.path("03_code", "lateral-raceway-422112-n7-eaceb5a518c5.json"))


setwd("C:/Users/6809758/Documents/GitHub/survey-procurers")

# Specify the column types
col_types <- cols(
  persistent_id = col_character(),
  buyer_id = col_character(),
  buyer_name = col_character(),
  .default = col_skip()
)


# Specify the locale with the encoding
locale <- locale(encoding = "UTF-8")  # Replace "UTF-8" with the actual encoding


#read_delim(file.path("02_data","01_raw","titl_data_05_12_2021.csv"),delim=";",escape_double = FALSE, trim_ws = TRUE)

# Import the data
data_all <- read_delim(file.path("02_data","01_raw","titl_data_05_12_2021.csv"),  delim=";", locale= locale)


# Select the columns you need
data <- data_all %>%
  select(persistent_id, buyer_id, buyer_name)


# Translate the buyer_name column from Czech to English
data$buyer_name_english <- text_translate(data$buyer_name, source = "cs", target = "en")

# Translate the buyer_name column from Czech to English
data$buyer_name_english <- sapply(data$buyer_name, function(x) {
  translate_text(x, source = "cs", target = "en")$input
})

