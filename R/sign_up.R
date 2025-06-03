#!/usr/bin/env R

# Copyright © 2025 OmicsChart Tech Ltd <info@omicschart.com>
# Distributed under terms of the MIT license.

#' Sign up for OmicsChart PREON
#'
#' @param email The email address of the user.
#' @param organization_name The name of the organization or affiliation.
#'
#' @return Invisibly returns `TRUE` if the request was successful.
#' @export
sign_up <- function(email, organization_name) {

  if (!requireNamespace("httr", quietly = TRUE)) {
    stop("Please install the 'httr' package.")
  }

  if (!grepl("^.+@.+\\..+$", email)) {
    stop("Invalid email address format.")
  }

  api_url <- getOption("omicschart.api_url", default = "https://api.omicschart.com")
  endpoint <- paste0(api_url, "/newUserSignup")

  response <- httr::POST(
    url = endpoint,
    encode = "json",
    body = list(email = email, organization_name = organization_name)
  )

  if (httr::http_error(response)) {
    msg <- tryCatch({
      httr::content(response, as = "text", encoding = "UTF-8")
    }, error = function(e) {
      response$status_code
    })
    stop("Signup failed: ", msg)
  }

  content <- jsonlite::fromJSON(httr::content(response))
  if (content$success) {
    message(content$message)
    return(invisible(TRUE))
  } else {
    warning(content$message)
    return(invisible(FALSE))
  }
}
