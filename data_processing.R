library(tidyverse)

# read in raw data
squirrels <- read_csv('data/raw/2018_Central_Park_Squirrel_Census.csv')

# clean Date column
squirrels <- squirrels |> 
  mutate(Date = as.Date(as.character(Date), format = "%m%d%Y"))

# clean column names
names(squirrels) <- names(squirrels) |> 
  str_to_lower() |> 
  str_replace_all(" ", "_")

# remove rows with unknown/missing age
squirrels <- squirrels |>
  filter(!is.na(age), age != "?")

# save to CSV
write_csv(squirrels, "data/processed/squirrels.csv")
