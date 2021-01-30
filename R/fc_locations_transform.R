#' Transform event locations
#'
#' This function transforms the Wyscout event data locations. By default,
#' the data provided is on a range of 0 - 100%. Thus, an x-y coordinate pair
#' of (50, 50) corresponds to midfield.
#'
#' @param data A data frame with event location data.
#' @param x A character vector identifying the variables for the x coordinate
#'   locations in \code{data}.
#' @param y A character vector identifying the variables for the y coordinate
#'   locations in \code{data}.
#' @param dim A numeric vector of length two giving the dimensions of how to
#'   transform the pitch. The x-dimension should be the first component.
#' @param units A character vector that provides units for the pitch
#'   dimensions. Use "percent" for when \code{dim = c(100, 100)}.
#'
#' @return A tidy tibble with x and y coordinates transformed according to
#'   \code{dim}. The resulting tibble will have "pitch_dimensions"
#'   and "units" attributes. These will be added or modified depending on if
#'   they exist for \code{data}.
#'
#' @references
#'   \emph{Pappalardo, L., Cintia, P., Rossi, A. et al. A public data
#'         set of spatio-temporal match events in soccer competitions. Sci
#'         Data 6, 236 (2019). \url{https://doi.org/10.1038/s41597-019-0247-7}}
#'
#'    All public Wyscout data is available at \url{https://figshare.com/collections/Soccer_match_event_dataset/4415000/2}
#'
#' @examples
#' # load dplyr for examples
#' library(dplyr)
#'
#' # read event data given in package
#' file_path <- system.file("extdata", "events_england.json", package = "scoutr")
#' events <- fc_read_events(file_path)
#'
#' result <- events %>%
#'   select(event_sec:end_y) %>%
#'   fc_locations_transform(x = c("start_x", "end_x"), y = c("start_y", "end_y"))
#'
#' # verify attributes
#' attr(result, "pitch_dimensions")
#' attr(result, "units")
#'
#' # transform to meters, then transform back
#' events %>%
#'   select(event_sec:end_y) %>%
#'   fc_locations_transform(x = c("start_x", "end_x"),
#'                          y = c("start_y", "end_y")) %>%
#'   fc_locations_transform(x = c("start_x", "end_x"),
#'                          y = c("start_y", "end_y"),
#'                          dim = c(100, 100), units = "percent")
#'
#' @import dplyr
#' @export

fc_locations_transform <- function(data, x, y, dim = c(105, 70), units = "meters") {

  if (is.null(attr(data, which = "pitch_dimensions"))) {
    result <- data %>%
      mutate_at(.vars = x, .funs = ~. * dim[1] / 100) %>%
      mutate_at(.vars = y, .funs = ~. * dim[2] / 100)

    attr(result, which = "units") <- units
    attr(result, which = "pitch_dimensions") <- dim
    cat("Attributes added: 'units', 'pitch_dimensions'\n")
    cat("Pitch dimensions:", paste0("(", dim[1], " X ", dim[2], ")"), units, "\n")

    return(result)
  } else {
    current_dim <- attr(data, which = "pitch_dimensions")

    result <- data %>%
      mutate_at(.vars = x, .funs = ~(. / current_dim[1]) * dim[1]) %>%
      mutate_at(.vars = y, .funs = ~(. / current_dim[2]) * dim[2])

    attr(result, which = "units") <- units
    attr(result, which = "pitch_dimensions") <- dim

    cat("Attributes modified: 'units', 'pitch_dimensions'\n")
    cat("Pitch dimensions:", paste0("(", dim[1], " X ", dim[2], ")"), units, "\n")

    return(result)
  }
}
