#' Read Wyscout soccer teams data
#'
#' This function reads and processes the Wyscout \code{teams} data.
#'
#' @param file File path to \code{teams} JSON data.
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
#' file_path <- system.file("extdata", "teams.json", package = "scoutr")
#'
#' teams <- read_teams(file_path)
#' teams_list <- read_teams(file_path, tidy_tibble = FALSE)
#'
#' @import dplyr
#' @import purrr
#' @importFrom jsonlite read_json
#' @importFrom janitor clean_names
#' @export

read_teams <- function(file, tidy_tibble = TRUE) {

  teams <- read_json(file)

  if (!tidy_tibble) {
    return(teams)
  }

  teams %>%
    map_df(unlist) %>%
    clean_names() %>%
    rename(area_alpha_3 = area_alpha3code,
           area_alpha_2 = area_alpha2code) %>%
    select(wy_id, official_name, name, area_name, city, area_id, area_alpha_2,
           area_alpha_3, type)
}
