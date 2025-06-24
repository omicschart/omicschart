#!/usr/bin/env R

# Copyright © 2025 OmicsChart Tech Ltd <info@omicschart.com>
# Distributed under terms of the MIT license.

#' Modify existing graph, move it into a different project, update description,
#' create a new version, change dimentions
#'
#' @param graph_uuid UUID of the graph to modify
#' @param graph (optional) Base plot function, ggplot2 or plotly object. If provided will generate a new version of the plot
#' @param description (optional) New description of the graph
#' @param dims (optional) New width and height in px
#' @param project_name (optional) Will move the graph into a project with specified name. The project has to exist!
#' @param public Boolean whether the graph should be available via public link
#'
#' @return UUID of the graph
#' @export
modify_graph <- function(
    graph_uuid,
    graph = NULL,
    description = NULL,
    dims = NULL,
    project_name = NULL,
    public = NULL
) {

  if (!requireNamespace("httr", quietly = TRUE)) stop("Please install 'httr'")
  if (!requireNamespace("magick", quietly = TRUE)) stop("Please install 'magick'")

  auth_config = readRDS(file.path(tools::R_user_dir("omicschart", "config"), "session.rds"))

  if (is.null(dims)) dims <- c(800, 400)

  ocplot_and_preview_list = list()
  if (!is.null(graph)) {
    ocplot_and_preview_list <- generate_ocplot_and_preview_from_r_plot(graph, dims)
  }

  api_url <- getOption("omicschart.api_url", default = "https://api.omicschart.com")
  endpoint <- paste0(api_url, "/modifyGraph")

  response <- httr::POST(
    url = endpoint,
    encode = "json",
    body = list(
      email = auth_config$email,
      uuid = graph_uuid,
      plot = ocplot_and_preview_list$ocplot,
      description = description,
      public = public,
      project = project,
      dims = as.list(dims),
      preview_base64 = ocplot_and_preview_list$preview_base64
    ),
    httr::add_headers(Authorization = paste("Bearer", auth_config$access_token))
  )

  if (httr::http_error(response)) {
    msg <- tryCatch({
      httr::content(response, as = "text", encoding = "UTF-8")
    }, error = function(e) {
      response$status_code
    })
    stop("Graph sharing failed: ", msg)
  }

  content <- jsonlite::fromJSON(httr::content(response))
  if (!content$success) stop("Graph sharing failed. Try again later.")

  message(content$message)

  return(graph_uuid)
}
