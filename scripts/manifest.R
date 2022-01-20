library(aws.s3)
library(data.table)
library(tidygraph)
library(tidyverse)

data_bucket <- "harvard-dataverse-trade"


#' Get data sets from a specified AWS bucket
#'
#' @param project_bucket Bucket to get data from
#' @param prefix Optional Prefix of folder whose content we want to get
#'
#' @return A data frame of objects stored on AWS
#' @export
#'
#' @examples
get_aws_files <- function(project_bucket = "harvard-dataverse-trade", prefix = "") {
  # Get AWS File Listing
  get_bucket(project_bucket, prefix = prefix) %>%
    transpose() %>%
    purrr::pluck("Key") %>%
    unlist() %>%
    tibble::as_tibble()
  
}


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
