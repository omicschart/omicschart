#!/usr/bin/env R

# Copyright © 2025 OmicsChart Tech Ltd <info@omicschart.com>
# Distributed under terms of the MIT license.

#' Generate JSON of OCPlot object and corresponding preview to be passed to the backend
#'
#' @param r_plot_object Base plot function, ggplot2 or plotly object.
#' @param dims Plot dimentions
#'
#' @return a list with 2 elements:
#'          ocplot - to be passed to R-backend and
#'          base64_preview - string of image scaled to 200 height
#' @noRd

generate_ocplot_and_preview_from_r_plot <- function(r_plot_object, dims){

  plot_list <- list(
    library = character(),
    component = character(),
    component_props = list()
  )

  if (inherits(r_plot_object, "gg")) {
    # ggplot, saving to file to be converted to base64 string
    plot_list$library = 'image'
    plot_list$component = 'img'
    tmp_image_file <- tempfile(fileext = ".png")
    ggplot2::ggsave(
      tmp_image_file,
      plot = r_plot_object,
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

  } else if (inherits(r_plot_object, "plotly")) {
    # plotly, saving as plotly json
    plot_list$library = 'plotly'
    plot_list$component = 'Plot'
    plot_list$component_props = jsonlite::fromJSON(plotly::plotly_json(r_plot_object, FALSE))
    preview_base64 <- create_base64_preview_from_plotly(r_plot_object)
  } else if (is.function(r_plot_object)) {
    # if a function for a base R plot, save to file
    plot_list$library = 'image'
    plot_list$component = 'img'
    tmp_image_file <- tempfile(fileext = ".png")
    grDevices::png(
      tmp_image_file,
      width = dims[1],
      height = dims[2],
      units = 'px',
      dpi = 72
    )
      r_plot_object()
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

  return(
    list(ocplot = plot_list, preview_base64 = preview_base64)
  )
}
