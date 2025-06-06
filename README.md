# OmicsChart PREON Utilities

An R package for sharing interactive results with peers, collecting feedback, and making adjustments based on that feedback.

## Installation

```r
# Install from GitHub
devtools::install_github("omicschart/omicschart")
```

## Authentication

Before using the package, you need to sign up and sign in to your OmicsChart account:

```r
# Sign up for a new account
sign_up(email = "your.email@example.com", organization_name = "Your organization")

# Sign in to your existing account
sign_in(email = "your.email@example.com")
```

## Usage

### Sharing Graphs

The main functions of this package is `share_graph()` and 
`<UNDER_DEVELOPMENT>share_report()`,
which allows you to share various types of R plots and Rmakrdown reports to 
OmicsChart PREON:

```r
# Share a ggplot2 plot
library(ggplot2)
p <- ggplot(mtcars, aes(mpg, wt)) + geom_point()
share_graph(p, description = "Miles per gallon vs Weight")

# Share a plotly plot
library(plotly)
p <- plot_ly(mtcars, x = ~mpg, y = ~wt, type = "scatter")
share_graph(p, description = "Interactive scatter plot")

# Share a base R plot
share_graph(function() plot(mtcars$mpg, mtcars$wt), 
           description = "Base R scatter plot")

# Share the current plot
plot(mtcars$mpg, mtcars$wt)
share_graph()  # Shares the last plot
```

### Parameters

The `share_graph()` function accepts the following parameters:

- `graph`: The plot to share (ggplot2, plotly, or base R plot function). If NULL, shares the current plot.
- `public`: Boolean indicating whether to generate a publicly accessible link (default: FALSE)
- `project`: Project name where the graph should be shared (default: "My Workspace")
- `description`: Description of the plot, used as a figure legend
- `dims`: Width and height in pixels (default: c(900, 600))

## Dependencies

The package requires the following R packages:
- httr
- jsonlite
- askpass
- magick
- htmlwidgets
- webshot2
- listviewer

## License

This package is distributed under the terms of the MIT license.

## Support

For support or questions, please contact tanya@omicschart.com 