library(data.table)
library(igraph)
library(ggraph)
library(tidygraph)
library(tidyverse)
#library(ggalluvial)


# Define helper function borrowed from John Graves' health-care-markets repo
# This function remove unnecessary axes from shape maps
remove_all_axes <- ggplot2::theme(
  axis.text = ggplot2::element_blank(),
  axis.line = ggplot2::element_blank(),
  axis.ticks = ggplot2::element_blank(),
  panel.border = ggplot2::element_blank(),
  panel.grid = ggplot2::element_blank(),
  axis.title = ggplot2::element_blank(),
  rect = element_blank(), 
  plot.background = element_blank()
)

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
  list.files(file.path("dataverse_files/"),recursive=TRUE, pattern = ".csv|.CSV") %>% 
  as_tibble() %>%
  filter(grepl("partner_sitcproduct4digit", value)) %>%
  pull(value)
  # Let us focus on the last 10 years. We will expand to include all 
  # the available data later
  
trade_df_all_years <-
  trade_data_all_years %>% 
  purrr::map(~(
    data.table::fread(file.path("dataverse_files",.x)) %>% as_tibble() %>%
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
      #mutate(exports = round(exports/1000000), imports = round(imports/1000000)) %>%
      filter(from_continent == "AF" & to_continent != "AF") %>%
      #filter(!(to_continent %in% c("AN", "OC"))) %>%
      mutate_at(.vars = c("from_continent", "to_continent"), as.factor) 
    
  )) %>%
  bind_rows()

# 2019 trade data
country_product_df <-
  fread("dataverse_files/country_partner_sitcproduct4digit_year_2019.csv") %>% 
  select(export_value, import_value, location_code, partner_code) %>%
  left_join(country_codes, by = c("location_code" = "country_code")) %>% 
  rename(from_continent = continent_name) %>% 
  left_join(country_codes, by = c("partner_code" = "country_code")) %>% 
  rename(to_continent = continent_name) %>% 
  filter(from_continent != to_continent) %>%
  group_by(from_continent, to_continent) %>% 
  summarize(exports = sum(export_value), imports = sum(import_value)) %>% 
  ungroup() %>%
  mutate_at(.vars = c("exports", "imports"), as.numeric) %>%
  #mutate(exports = round(exports/1000000), imports = round(imports/1000000)) %>%
  filter(from_continent == "AF" & to_continent != "AF") %>%
  filter(!(to_continent %in% c("AN", "OC"))) %>%
  mutate_at(.vars = c("from_continent", "to_continent"), as.factor) 
  

africa_exports_2019 <-
  trade_df_all_years %>% 
  filter(year > 2018) %>% 
  ggplot(data = .,
         aes(axis1 = from_continent, axis2 = to_continent, y = exports)) +
  labs(title = "Aggregated Exports from Africa to the World",
       subtitle = "2019",
       caption  = "Data from the Harvard dataverse.") +
  theme(plot.caption = element_text(hjust = 0, face= "italic"), #Default is hjust=1
        plot.title.position = "plot", #NEW parameter. Apply for subtitle too.
        plot.caption.position =  "plot") %>% #NEW parameter 
  facet_graph(.~year)
  

## Code to refer to when creating flows. From John Graves' health-care-markets repository on github.

###########################################################
###########################################################
# Create function to convert dataframe to bipartite matrix
#' Title
#'
#' @param df 
#' @param id 
#'
#' @return
#' @export
#'
#' @examples
convert_to_bipartite <- function(df,id) {
  id <- enquo(id)
  nn <- df %>% pull(!!id)
  foo <- df %>% select(-!!id) %>%
    as.matrix()
  
  rownames(foo) <- nn
  foo
}

bp_cont_exports_weighted <-
  #country_product_df %>%
  trade_df_all_years %>%
  filter(year > 2017) %>%
  select(year, from_continent, to_continent, exports) %>%
  spread(to_continent, exports) %>%
  convert_to_bipartite(id = from_continent)
bp_cont_exports_weighted[is.na(bp_cont_exports_weighted)] <- 0

net_bp <-
  graph_from_incidence_matrix(bp_cont_exports_weighted,weighted=TRUE) %>%
  as_tbl_graph() %>%
  activate(nodes) 



set.seed(1)
net_bp %>%
  ggraph(layout='lgl') +
  geom_edge_link(aes(width = weight,alpha=weight),show.legend = FALSE) +
  geom_node_point(aes(colour=type), cex = 6) +
  geom_node_text(aes(label = name),cex = 3) +
  remove_all_axes  +
  theme(legend.position = "none")
  

# References
# 1. Network analysis. https://sites.fas.harvard.edu/~airoldi/pub/books/BookDraft-CsardiNepuszAiroldi2016.pdf
