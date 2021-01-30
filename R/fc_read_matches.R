#' Read Wyscout soccer matches data
#'
#' This function reads and processes the Wyscout \code{matches} data.
#'
#' @param file File path to \code{matches} JSON data.
#' @param tidy_tibble Logical value indicating if the returned object should be
#'   a tidy tibble or not. If \code{FALSE}, a list is returned.
#'
#' @return A tidy tibble or list depending on the value of argument
#'   \code{tidy_tibble}. A detailed description of the variables is given
#'   at the reference cited below. Not all variables are returned from the
#'   original JSON data file. Specifically, referee data is not included
#'   in the tidy tibble object, and only some data from nested section
#'   \code{teamsData} is included in the tidy tibble object.
#'
#' @note The variable names in the returned tidy tibble are in snake case, but
#'   they are analogous to those used by Wyscout.
#'
#' @references
#'   \emph{Pappalardo, L., Cintia, P., Rossi, A. et al. A public data
#'         set of spatio-temporal match events in soccer competitions. Sci
#'         Data 6, 236 (2019). \url{https://doi.org/10.1038/s41597-019-0247-7}}
#'
#'   All public Wyscout data is available at \url{https://figshare.com/collections/Soccer_match_event_dataset/4415000/2}
#'
#' @family read functions
#' @seealso
#'
#' @examples
#' file_path <- system.file("extdata", "matches_england.json", package = "scoutr")
#'
#' matches <- fc_read_matches(file_path)
#' matches_list <- fc_read_matches(file_path, tidy_tibble = FALSE)
#'
#' @import dplyr
#' @import purrr
#' @import tidyr
#' @importFrom jsonlite read_json
#' @importFrom janitor clean_names
#' @importFrom rlang .data
#' @export

fc_read_matches <- function(file, tidy_tibble = TRUE) {

  matches <- read_json(file)

  if (!tidy_tibble) {
    return(matches)
  }
  side <- teamId <- score <- NULL
  get_team_info <- function(x) {
    map_df(x$teamsData, `[`, c("side", "teamId", "score")) %>%
      pivot_wider(names_from = side, values_from = teamId:score)
  }

  bind_cols(
    map_df(matches, `[`, c("wyId", "date", "label", "winner", "gameweek",
                           "duration", "competitionId", "venue", "dateutc",
                           "seasonId", "roundId", "status")),
    map_df(matches, get_team_info)) %>%
    clean_names() %>%
    rename(game_week = .data$gameweek,
           date_utc  = .data$dateutc) %>%
    mutate_all(as.character) %>%
    mutate_at(vars(starts_with("score_")), as.integer) %>%
    select(.data$wy_id, .data$date, .data$date_utc, .data$label, .data$winner,
           starts_with("team_id"), starts_with("score"), .data$duration,
           .data$venue, .data$game_week, .data$season_id,
           .data$round_id, .data$competition_id, .data$status)
}
