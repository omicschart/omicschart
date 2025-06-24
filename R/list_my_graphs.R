#!/usr/bin/env R

# Copyright © 2025 OmicsChart Tech Ltd <info@omicschart.com>
# Distributed under terms of the MIT license.

#' List graphs that are shared with or created by you
#'
#' @param project_name filter only to the graphs of the given project, or
#'    specify "all" to view all graphs that are available to you. If not
#'    specified, current active project will be selected
#'
#' @return data.frame with graphs description, uuid, created_by and latest version number
#' @export
list_my_graphs <- function( project_name = NULL ) {

  if (!requireNamespace("httr", quietly = TRUE)) stop("Please install 'httr'")
  if (!requireNamespace("magick", quietly = TRUE)) stop("Please install 'magick'")

  auth_config = readRDS(file.path(tools::R_user_dir("omicschart", "config"), "session.rds"))
  active_project_name = ifelse(
    is.null(project_name),
    auth_config$active_project_name,
    project_name
  )

  api_url <- getOption("omicschart.api_url", default = "https://api.omicschart.com")

  response <- httr::POST(
    url = paste0(api_url, "/getGraphs"),
    encode = "json",
    body = list(
      email = auth_config$email,
      project_name = active_project_name
    ),
    httr::add_headers(Authorization = paste("Bearer", auth_config$access_token))
  )

  if (httr::http_error(response)) {
    msg <- tryCatch({
      httr::content(response, as = "text", encoding = "UTF-8")
    }, error = function(e) {
      response$status_code
    })
    stop("Fetching graphs failed: ", msg)
  }

  graphs_df <- jsonlite::fromJSON(httr::content(response))$graphs_table
  return(graphs_df)
}
