#' Encode single-match consecutive passes
#'
#' This function encodes consecutive passing sequences for a single match
#' using event data.
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
#' @return A tidy tibble that contains only \code{Pass} events from \code{data},
#'   and \code{pass_id} and \code{pass_seq} variables. Variable \code{pass_id}
#'   maps each pass event event to a consecutive pass sequence within a game.
#'   Variable \code{pass_seq} provides a running count of pass events within a
#'   passing sequence.
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
#' fc_sequence_pass(events, event_var = "event_name", team_var = "team_id") %>%
#'   select(event_name, team_id, pass_id, pass_seq)
#'
#' # multi-match example (fake)
#' y <- left_join(events, teams, by = c("team_id" = "wy_id")) %>%
#'   select(match_id, event_name, sub_event_name, team_id, name) %>%
#'   slice(1:10) %>%
#'   mutate(match_id = as.character(c(rep(1, 5), rep(2, 5))))
#'
#' map_df(unique(y$match_id), fc_sequence_pass, data = y,
#'                            event_var = "event_name", team_var = "name")
#'
#' @import dplyr
#' @import purrr
#' @export

fc_sequence_pass <- function(data, event_var, team_var, match = NULL) {

  if (!is.null(match)) {
    data <- data %>%
      filter(.data$match_id == match)
  }

  data %>%
    filter(get(event_var) == "Pass") %>%
    mutate(pass_id  = rep(seq_along(rle(.data[[team_var]])$lengths),
                          times = rle(.data[[team_var]])$lengths),
           pass_seq = unlist(sapply(rle(.data[[team_var]])$lengths, seq)))
}
