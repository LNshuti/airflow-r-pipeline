# Load necessary libraries and functions
source(here::here("/scripts/manifest.R"))

continental_trade_df <- 
  get_aws_files(prefix = "processed") %>%
  filter(grepl(".Rds", value)) %>% 
  pull(value) %>% 
  purrr::map(~(
    s3readRDS(data.table::fread,bucket = data_bucket,object = paste0(.x)))
    ) %>% 
  bind_rows()

bp_cont_exports_weighted <-
  continental_trade_df %>%
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
