#!/usr/bin/env R

# Copyright © 2025 OmicsChart Tech Ltd <info@omicschart.com>
# Distributed under terms of the MIT license.

#' UNDER DEVELOPMENT Share HTML and PDF outputs of rmd to PREON
#'
#' @param rmd_file path to .rmd rmarkdown document
#' @param project Project name where the report should be shared to. By default is it shared in active project (if set) or in personal workspace
#' @param title Report title. Used to display report in the list of reports. By default title from the header is used
#'
#' @return UUID of the report
#' @export
share_rmd_report <- function(rmd_file, project = "My Workspace", title = NULL) {

  stop("UNDER DEVELOPMENT")
  auth_config = readRDS(file.path(tools::R_user_dir("omicschart", "config"), "session.rds"))

  api_url <- getOption("omicschart.api_url", default = "https://api.omicschart.com")
  endpoint <- paste0(api_url, "/shareReportToPreon")

  response <- httr::POST(
    url = endpoint,
    encode = "json",
    body = list(
      pdf_report = ,
      html_report = ,
      ...
    ),
    httr::add_headers(Authorization = paste("Bearer", auth_config$access_token))
  )

  if (httr::http_error(response)) {
    msg <- tryCatch({
      httr::content(response, as = "text", encoding = "UTF-8")
    }, error = function(e) {
      response$status_code
    })
    stop("Report sharing failed: ", msg)
  }

  content <- jsonlite::fromJSON(httr::content(response))
  if (!content$success) stop("Report sharing failed. Try again later.")

  message("Report shared successfully. ", content$message)
  return(content$uuid)
}
