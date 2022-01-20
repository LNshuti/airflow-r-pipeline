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

# Set seed to allow replication
set.seed(9867891)
net_bp %>%
  ggraph(layout='lgl') +
  geom_edge_link(aes(width = weight,alpha=weight),show.legend = FALSE) +
  geom_node_point(aes(colour=type), cex = 6) +
  geom_node_text(aes(label = name),cex = 3) +
  remove_all_axes  +
  theme(legend.position = "none")


trade_over_time_plt <- 
  ggraph(hairball, layout = 'kk') + 
  geom_edge_density(aes(fill = year)) + 
  geom_edge_link(alpha = 0.25)


ggraph(simple, layout = 'graphopt') + 
  geom_edge_link(aes(start_cap = label_rect(node1.name),
                     end_cap = label_rect(node2.name)), 
                 arrow = arrow(length = unit(4, 'mm'))) + 
  geom_node_text(aes(label = name))

flaregraph <- graph_from_data_frame(flare$edges, vertices = flare$vertices)
from <- match(flare$imports$from, flare$vertices$name)
to <- match(flare$imports$to, flare$vertices$name)
ggraph(flaregraph, layout = 'dendrogram', circular = TRUE) + 
  geom_conn_bundle(data = get_con(from = from, to = to), alpha = 0.1) + 
  coord_fixed()


s3save(trade_over_time, object = "plots/trade_over_time.png", bucket = data_bucket)



# References
# 1. Network analysis. https://sites.fas.harvard.edu/~airoldi/pub/books/BookDraft-CsardiNepuszAiroldi2016.pdf
# 2. Introduction to ggraph: Edges. Data Imaginist. https://www.data-imaginist.com/2017/ggraph-introduction-edges/
