#!/usr/bin/env R

# Copyright © 2025 OmicsChart Tech Ltd <info@omicschart.com>
# Distributed under terms of the MIT license.

#' Sign into OmicsChart PREON from R
#'
#' @param graph Base plot function, ggplot2 or plotly object, or NULL for sharing current plot
#' @param public Boolean whether the publicly accessible link should be generated
#' @param project Project name where the graph should be shared to. By default is it shared in personal space
#' @param description Description of the plot, a figure legend.
#' @param dims width and height in px
#'
#' @return UUID of the graph
#' @export
share_graph <- function(
  graph = NULL,
  public = FALSE,
  project = "My Workspace",
  description = "",
  dims = c(900, 600)
) {

  if (!requireNamespace("httr", quietly = TRUE)) stop("Please install 'httr'")
  if (!requireNamespace("magick", quietly = TRUE)) stop("Please install 'magick'")

  auth_config = readRDS(file.path(tools::R_user_dir("omicschart", "config"), "session.rds"))

  plot_list <- list(
    library = character(),
    component = character(),
    component_props = list()
  )

  if (!is.null(graph)) {

    if (inherits(graph, "gg")) {
      # ggplot, saving to file to be converted to base64 string

      plot_list$library = 'image'
      plot_list$component = 'img'
      tmp_image_file <- tempfile(fileext = ".png")
      ggplot2::ggsave(
        tmp_image_file,
        plot = graph,
        width = dims[1],
        height = dims[2],
        units = 'px',
        dpi = 72
      )
      plot_list$component_props$src <- paste0(
        "data:image/png;base64,",
        base64enc::base64encode(tmp_image_file)
      )
      preview_base64 <- create_base64_preview_from_png(tmp_image_file)
      unlink(tmp_image_file)

    } else if (inherits(graph, "plotly")) {
      # plotly, saving as plotly json
      plot_list$library = 'plotly'
      plot_list$component = 'Plot'
      plot_list$component_props = jsonlite::fromJSON(plotly::plotly_json(graph, FALSE))
      preview_base64 <- create_base64_preview_from_plotly(graph)
    } else if (is.function(graph)) {
      # if a function for a base R plot, save to file
      plot_list$library = 'image'
      plot_list$component = 'img'
      tmp_image_file <- tempfile(fileext = ".png")
      grDevices::png(tmp_image_file)
        graph()
      grDevices::dev.off()
      plot_list$component_props$src <- paste0(
        "data:image/png;base64,",
        base64enc::base64encode(tmp_image_file)
      )
      preview_base64 <- create_base64_preview_from_png(tmp_image_file)
      unlink(tmp_image_file)
    } else {
      stop("Unsupported plot type. Must be a ggplot, plotly, or a base R plot function.")
    }
  } else {
    # if graph is NULL, capture the last image from plot panel
    tryCatch({
      last_plot = grDevices::recordPlot()
    }, error = function(e) {
        stop("No plot to capture. Please draw a plot before calling `share_graph()`.")
    })
    plot_list$library = 'image'
    plot_list$component = 'img'
    dims <- grDevices::dev.size("px")
    tmp_image_file <- tempfile(fileext = ".png")
    grDevices::png(tmp_image_file, width = dims[1], height = dims[2], units = "px")
      grDevices::replayPlot(last_plot)
    grDevices::dev.off()
    plot_list$component_props$src <- paste0(
      "data:image/png;base64,",
      base64enc::base64encode(tmp_image_file)
    )
    preview_base64 <- create_base64_preview_from_png(tmp_image_file)
    unlink(tmp_image_file)
  }

  api_url <- getOption("omicschart.api_url", default = "https://api.omicschart.com")
  endpoint <- paste0(api_url, "/shareGraphToPreon")

  response <- httr::POST(
    url = endpoint,
    encode = "json",
    body = list(
      email = auth_config$email,
      plot = plot_list,
      description = description,
      public = public,
      project = project,
      dims = dims,
      preview_base64 = preview_base64
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

  if (public)
  {
    message("Graph shared successfully. View it at https://preon.omicschart.com/shared_graph?uuid=", content$uuid)
  } else {
    message("Graph shared successfully. ", content$message)
  }
  return(content$uuid)
}
