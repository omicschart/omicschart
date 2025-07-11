#!/usr/bin/env R

# Copyright © 2025 OmicsChart Tech Ltd <info@omicschart.com>
# Distributed under terms of the MIT license.

#' Sign into OmicsChart PREON from R
#'
#' @param email User email
#' @return Invisibly returns TRUE if login was successful.
#' @export
sign_in <- function(email) {
  if (!requireNamespace("httr", quietly = TRUE)) stop("Please install 'httr'")
  if (!requireNamespace("askpass", quietly = TRUE)) stop("Please install 'askpass'")
  if (!grepl("@", email)) stop("Invalid email format")

  password <- askpass::askpass("Enter your OmicsChart PREON password:")
  if (is.null(password) || password == "") stop("Sign-in cancelled.")

  api_url <- getOption("omicschart.api_url", default = "https://api.omicschart.com")
  endpoint <- paste0(api_url, "/userSignIn")

  response <- httr::POST(
    url = endpoint,
    encode = "json",
    body = list(email = email, password = password)
  )

  if (httr::http_error(response)) {
    msg <- tryCatch({
      httr::content(response, as = "text", encoding = "UTF-8")
    }, error = function(e) {
      response$status_code
    })
    stop("Sign-in failed: ", msg)
  }

  content <- jsonlite::fromJSON(httr::content(response))
  if (!content$success) stop("Login failed. Try again later.")

  # Save session to config path
  session <- list(
    email = email,
    access_token = content$access_token,
    refresh_token = content$refresh_token,
    expires_at = Sys.time() + 3600,
    organization_name = content$organization_name,
    active_project_name = content$active_project_name
  )

  dir.create(tools::R_user_dir("omicschart", "config"), recursive = TRUE, showWarnings = FALSE)
  saveRDS(session, file.path(tools::R_user_dir("omicschart", "config"), "session.rds"))

  message("Sign-in successful.")
  invisible(TRUE)
}
