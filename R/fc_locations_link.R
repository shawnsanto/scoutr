#' Link event locations
#'
#' This function converts \code{data} from a tibble to a simple feature object
#' by adding a linestring geometry that links the starting and ending locations
#' of each event in \code{data}.
#'
#' @param data A data frame with event location data.
#' @param start_loc A character vector identifying the \code{x} and \code{y}
#'   coordinates for the start of an event in \code{data}.
#' @param end_loc A character vector identifying the \code{x} and \code{y}
#'   coordinates for the end of an event in \code{data}.
#'
#' @return A simple feature object with a new variable named \code{geometry}.
#'   The variable \code{geometry} is a linestring object.
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
#' events %>%
#'   select(event_sec:end_y) %>%
#'   fc_locations_transform(x = c("start_x", "end_x"), y = c("start_y", "end_y")) %>%
#'   fc_locations_link(start_loc = c("start_x", "start_y"), end_loc = c("end_x", "end_y"))
#'
#' @import dplyr
#' @import purrr
#' @import sf
#' @export

fc_locations_link <- function(data, start_loc, end_loc) {

  create_line <- function(start_x, start_y, end_x, end_y) {
    st_linestring(matrix(c(start_x, end_x, start_y, end_y), 2, 2))
  }

  data %>%
    select(all_of(c(start_loc, end_loc))) %>%
    pmap(create_line) %>%
    st_as_sfc() %>%
    tibble(data, geometry = .) %>%
    st_sf()
}
