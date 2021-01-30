#' Compute velocity of events
#'
#' This function computes velocities for each event in the event location
#' data.
#'
#' @param data A data frame with event location data. \code{data} at minimum
#'   must contain variables named \code{match_id}, \code{match_period},
#'   \code{possession_id}, and \code{event_sec}.
#' @param start_loc A character vector identifying the \code{x} and \code{y}
#'   coordinates for the start of an event in \code{data}.
#' @param end_loc A character vector identifying the \code{x} and \code{y}
#'   coordinates for the end of an event in \code{data}.
#' @param direction A character vector specifying the direction of velocity to
#'   compute. It can be a subset of \code{c("east", "west", "north", "south",
#'   "east_west", "north_south")}. The default value computes all six velocities
#'   and the total \code{speed}. Setting \code{direction = NULL} will only
#'   compute the total \code{speed}.
#'
#' @return A tidy tibble with mutated columns giving the velocities specified
#'   by \code{direction}.
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
#'
#' events <- fc_read_events(file_path) %>%
#'   fc_locations_transform(x = c("start_x", "end_x"), y = c("start_y", "end_y")) %>%
#'   fc_sequence_possession(event_var = "event_name", team_var = "team_id") %>%
#'   select(match_id, match_period, possession_id, event_sec:end_y)
#'
#' # compute all velocities and speed
#' events %>%
#'   fc_velocity_event(start_loc = c("start_x", "start_y"), end_loc = c("end_x", "end_y"),
#'                     direction = "all")
#'
#' # compute speed
#' events %>%
#'   fc_velocity_event(start_loc = c("start_x", "start_y"), end_loc = c("end_x", "end_y"),
#'                     direction = NULL)
#'
#' # compute a subset of velocities
#' events %>%
#'   fc_velocity_event(start_loc = c("start_x", "start_y"), end_loc = c("end_x", "end_y"),
#'                     direction = c("east_west", "north_south"))
#'
#' @import dplyr
#' @import purrr
#' @export

fc_velocity_event <- function(data, start_loc, end_loc, direction = "all") {

  required_vars <- c("match_id", "match_period", "possession_id", "event_sec",
                     start_loc, end_loc)
  if (any(!required_vars %in% names(data))) {
    stop(cat("Missing at least one of the following variables in data: ",
         required_vars, "\n"))
  }

  start_x <- start_loc[1]
  end_x <- end_loc[1]
  start_y <- start_loc[2]
  end_y <- end_loc[2]

  velocity_fcn_list <- list(
    east_velocity        = function(df) {
      ifelse(((df[[end_x]] - df[[start_x]]) / df$duration) > 0,
             (df[[end_x]] - df[[start_x]]) / df$duration, 0)
    },
    west_velocity        = function(df) {
      ifelse(((df[[end_x]] - df[[start_x]]) / df$duration) < 0,
             (df[[end_x]] - df[[start_x]]) / df$duration, 0)
    },
    north_velocity       = function(df) {
      ifelse(((df[[end_y]] - df[[start_y]]) / df$duration) > 0,
             (df[[end_y]] - df[[start_y]]) / df$duration, 0)
    },
    south_velocity       = function(df) {
      ifelse(((df[[end_y]] - df[[start_y]]) / df$duration) < 0,
             (df[[end_y]] - df[[start_y]]) / df$duration, 0)
    },
    east_west_velocity   = function(df) abs(df[[end_x]] - df[[start_x]]) / df$duration,
    north_south_velocity = function(df) abs(df[[end_y]] - df[[start_y]]) / df$duration,
    speed                = function(df) {
      sqrt(abs(df[[end_x]] - df[[start_x]])^2 + abs(df[[end_y]] - df[[start_y]])^2) / df$duration
    }
  )

  if (is.null(direction)) {
    velocity_fcn_list <- velocity_fcn_list["speed"]
  }

  if (!("all" %in% direction) && !is.null(direction)) {
    direction <- paste0(direction, "_velocity")
    velocity_fcn_list <- velocity_fcn_list[direction]
  }

  data %>%
    group_by(.data$match_id, .data$match_period, .data$possession_id) %>%
    mutate(duration = lead(.data$event_sec) - .data$event_sec) %>%
    ungroup() %>%
    bind_cols(invoke_map_df(velocity_fcn_list, df = .)) %>%
    mutate(across(.fns = ~ifelse(is.infinite(.x), NA, .x))) %>%
    mutate(across(.cols = ends_with("_velocity"), .fns = abs))
}
