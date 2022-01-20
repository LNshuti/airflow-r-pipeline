# Load necessary libraries and functions
source(here::here("/scripts/manifest.R"))


# Import country identifiers 
countryweb <-
  "https://pkgstore.datahub.io/JohnSnowLabs/country-and-continent-codes-list/country-and-continent-codes-list-csv_csv/data/b7876b7f496677669644f3d1069d3121/country-and-continent-codes-list-csv_csv.csv"

# Get African country codes
country_codes <- 
  read.csv(countryweb) %>% 
  janitor::clean_names() %>% 
  select(continent_code, country_code = three_letter_country_code) %>%
  rename(continent_name =continent_code)

# Combine trade data from 1962 to 2019
trade_data_all_years <- 
  get_aws_files() %>%
  filter(grepl("partner_sitcproduct4digit", value)) %>%
  pull(value)

trade_df_all_years <-
  trade_data_all_years %>% 
  purrr::map(~(
    s3read_using(data.table::fread,bucket = data_bucket,object = paste0(.x))  %>%
      select(year, export_value, import_value, location_code, partner_code) %>%
      left_join(country_codes, by = c("location_code" = "country_code")) %>% 
      rename(from_continent = continent_name) %>% 
      left_join(country_codes, by = c("partner_code" = "country_code")) %>% 
      rename(to_continent = continent_name) %>% 
      filter(from_continent != to_continent) %>%
      group_by(year, from_continent, to_continent) %>% 
      summarize(exports = sum(export_value), imports = sum(import_value)) %>% 
      ungroup() %>%
      mutate_at(.vars = c("exports", "imports"), as.numeric) %>%
      filter(from_continent == "AF" & to_continent != "AF") %>%
      mutate_at(.vars = c("from_continent", "to_continent"), as.factor) 
    
  )) %>%
  bind_rows()


s3saveRDS(x = trade_df_all_years, 
          bucket = data_bucket,
          object = "processed/continental_import_export_1962_2019.Rds")
