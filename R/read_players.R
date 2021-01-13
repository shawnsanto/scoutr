#' Read Wyscout soccer players data
#'
#' This function reads and processes the Wyscout \code{players} data.
#'
#' @param file File path to \code{players} JSON data.
#' @param tidy_tibble Logical value indicating if the returned object should be
#'   a tidy tibble or not. If \code{FALSE}, a list is returned.
#'
#' @return A tidy tibble or list depending on the value of argument
#'   \code{tidy_tibble}. A detailed description of the variables is given
#'   at the reference cited below.
#'
#' @note The variable names in the returned tidy tibble are in snake case, but
#'   they are analogous to those used by Wyscout.
#'
#' @references
#'   \emph{Pappalardo, L., Cintia, P., Rossi, A. et al. A public data
#'         set of spatio-temporal match events in soccer competitions. Sci
#'         Data 6, 236 (2019). \url{https://doi.org/10.1038/s41597-019-0247-7}}
#'
#'    All public Wyscout data is available at \url{https://figshare.com/collections/Soccer_match_event_dataset/4415000/2}
#'
#' @family read functions
#' @seealso
#'
#' @examples
#' file_path <- system.file("extdata", "players.json", package = "scoutr")
#'
#' players <- read_players(file_path)
#' players_list <- read_players(file_path, tidy_tibble = FALSE)
#'
#' @import dplyr
#' @import purrr
#' @importFrom jsonlite read_json
#' @importFrom janitor clean_names
#' @importFrom rlang .data
#' @export

read_players <- function(file, tidy_tibble = TRUE) {

  players <- read_json(file)

  if (!tidy_tibble) {
    return(players)
  }

  map_df(players, unlist) %>%
    clean_names() %>%
    rename(passport_area_alpha_3 = .data$passport_area_alpha3code,
           passport_area_alpha_2 = .data$passport_area_alpha2code) %>%
    rename(birth_area_alpha_3 = .data$birth_area_alpha3code,
           birth_area_alpha_2 = .data$birth_area_alpha2code) %>%
    mutate(height     = as.integer(.data$height),
           weight     = as.integer(.data$weight),
           birth_date = as.Date(.data$birth_date)) %>%
    select(.data$wy_id, .data$first_name, .data$middle_name, .data$last_name,
           .data$short_name, .data$birth_date,
           .data$height, .data$weight, .data$foot, .data$current_team_id,
           .data$current_national_team_id,
           contains("role_"), contains("passport_area"),
           contains("birth_area_"))
}
