#!/usr/bin/env R

# Copyright © 2025 OmicsChart Tech Ltd <info@omicschart.com>
# Distributed under terms of the MIT license.

#' Generate base64 preview string from the full-size png file with an original image
#'
#' @param png_file_path full path to a png file with an image
#'
#' @return a base64 string of image scaled to 200 height
#' @noRd

create_base64_preview_from_png <- function(png_file_path){

  # creating a preview base64 image
  preview_image = magick::image_scale(
    magick::image_read(png_file_path),
    "200x"
  )

  preview_file <- tempfile(fileext = ".png")
  magick::image_write(preview_image, path = preview_file)
  base64_preview <- paste0(
    "data:image/png;base64,",
    base64enc::base64encode(preview_file)
  )

  # deleting tmp file
  unlink(preview_file)

  return(base64_preview)
}
