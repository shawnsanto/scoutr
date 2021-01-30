#' Encode single-match possessions
#'
#' This function encodes possession sequences for a single match using event
#' data.
#'
#' @param data A data frame of event data.
#' @param event_var A character value identifying the variable name that
#'   corresponds to the event classification for a given event in \code{data}.
#' @param team_var A character value identifying the variable name that
#'   corresponds to the team label for a given event in \code{data}.
#' @param match A character vector of match id values.
#'   Only required to define possession ids and sequences in
#'   multi-match data frames. See example below.
#'
#' @return A tidy tibble that contains \code{data}, and \code{possession_id} and
#'   \code{possession_seq} variables. Variable \code{possession_id} maps each
#'   event to a possession within a game. Variable \code{possession_seq}
#'   provides a running count of events within a possession.
#'
#' @references
#'   \emph{Pappalardo, L., Cintia, P., Rossi, A. et al. A public data
#'         set of spatio-temporal match events in soccer competitions. Sci
#'         Data 6, 236 (2019). \url{https://doi.org/10.1038/s41597-019-0247-7}}
#'
#'    All public Wyscout data is available at \url{https://figshare.com/collections/Soccer_match_event_dataset/4415000/2}
#'
#' @examples
#' # load dplyr and purrr for examples
#' library(dplyr)
#' library(purrr)
#'
#' # read event and teams data given in package
#' events <- system.file("extdata", "events_england.json", package = "scoutr") %>%
#'   fc_read_events()
#' teams <- system.file("extdata", "teams.json", package = "scoutr") %>%
#'   fc_read_teams()
#'
#' # join events and teams data
#' x <- left_join(events, teams, by = c("team_id" = "wy_id")) %>%
#'   select(match_id, event_name, sub_event_name, team_id, name)
#'
#' fc_sequence_possession(x, event_var = "event_name", team_var = "name")
#'
#' # multi-match example (fake)
#' y <- left_join(events, teams, by = c("team_id" = "wy_id")) %>%
#'   select(match_id, event_name, sub_event_name, team_id, name) %>%
#'   slice(1:10) %>%
#'   mutate(match_id = as.character(c(rep(1, 5), rep(2, 5))))
#'
#' map_df(unique(y$match_id), fc_sequence_possession, data = y,
#'                            event_var = "event_name", team_var = "name")
#'
#' @import dplyr
#' @import purrr
#' @export

fc_sequence_possession <- function(data, event_var, team_var, match = NULL) {

  if (!is.null(match)) {
    data <- data %>%
      filter(.data$match_id == match)
  }

  continuation_events <- c("Duel", "Others on the ball")
  barrier_events <- c("Foul", "Free Kick", "Interruption",
                      "Offside", "Shot", "Save attempt")
  pid <- 1
  pvec <- 1
  passes <- which(data[[event_var]] == "Pass")

  for (i in 2:nrow(data)) {
    # handle duels and others on the ball events
    if (data[[event_var]][i] %in% continuation_events) {
      previous_pass <- ifelse(purrr::is_empty(passes[passes < i]),
                              i, max(passes[passes < i]))
      next_pass <- ifelse(i > previous_pass,
                          previous_pass, min(passes[passes > i]))

      if (data[[team_var]][previous_pass] == data[[team_var]][next_pass]) {
        pvec <- c(pvec, pid)
      } else if ((data[[event_var]][i + 1] == continuation_events[1]) ||
                 (data[[team_var]][i] == data[[team_var]][previous_pass])) {
        pvec <- c(pvec, pid)
      } else {
        pid <-  pid + 1
        pvec <- c(pvec, pid)
      }
    # handle barrier events
    } else if (data[[event_var]][i] %in% barrier_events) {
      if (data[[event_var]][i - 1] %in% barrier_events) {
        pid <- pid + 1
        pvec <- c(pvec, pid)
      } else {
        pvec <- c(pvec, pid)
      }
    # handle pass events
    } else if (data[[event_var]][i] == "Pass") {
      previous_pass <- ifelse(purrr::is_empty(passes[passes < i]),
                              i, max(passes[passes < i]))
      if ((data[[event_var]][i - 1] == barrier_events[2]) &&
          (data[[team_var]][i] == data[[team_var]][i - 1])) {
        pvec <- c(pvec, pid)
      } else if (data[[team_var]][i] == data[[team_var]][previous_pass]) {
        pvec <- c(pvec, pid)
      } else {
        pid <-  pid + 1
        pvec <- c(pvec, pid)
      }
    } else {
      pvec <- c(pvec, pid)
    }
  }
  data %>%
    mutate(possession_id  = pvec,
           possession_seq = unlist(sapply(rle(.data$possession_id)$lengths, seq)))
}
