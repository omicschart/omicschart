#!/usr/bin/env R

# Copyright © 2025 OmicsChart Tech Ltd <info@omicschart.com>
# Distributed under terms of the MIT license.

#' Generate base64 preview string from the full-size plotly image
#'
#' @param plotly_image plotly image
#'
#' @return a base64 string of image scaled to 200 height
#' @noRd

create_base64_preview_from_plotly <- function(plotly_image){

  tmp_html <- tempfile(fileext = ".html")
  tmp_png  <- tempfile(fileext = ".png")
  tmp_preview_png <- tempfile(fileext = ".png")

  htmlwidgets::saveWidget(plotly_image, tmp_html, selfcontained = TRUE)
  webshot2::webshot(tmp_html, file = tmp_png)

  # Scale down PNG
  preview_img <- magick::image_scale( magick::image_read(tmp_png), "200x")
  magick::image_write(preview_img, tmp_preview_png)

  base64_preview <- paste0(
    "data:image/png;base64,",
    base64enc::base64encode(tmp_preview_png)
  )

  #deleting all tmp files
  unlink(tmp_html)
  unlink(tmp_png)
  unlink(tmp_preview_png)

  return(base64_preview)
}
