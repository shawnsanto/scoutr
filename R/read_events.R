#' Read Wyscout soccer events data
#'
#' This function reads and processes the Wyscout \code{events} data.
#'
#' @param file File path to \code{events} JSON data.
#' @param tidy_tibble Logical value indicating if the returned object should be
#'   a tidy tibble or not. If \code{FALSE}, a list is returned.
#' @param keep_tags Logical value indicating if \code{tag} variables should be
#'   included in the returned tidy tibble or not. If \code{tidy_tibble} is
#'   \code{FALSE}, \code{tag} variables are always included.
#'
#' @return A tidy tibble or list depending on the value of argument
#'   \code{tidy_tibble}. A detailed description of the variables is given
#'   at the reference cited below.
#'
#' @note These files are typically the largest and take the longest to process.
#'   Expect it to take around two minutes to read in a year of event data for
#'   a single league. The variable names in the returned tidy tibble are in
#'   snake case, but they are analogous to those used by Wyscout.
#'
#'   The JSON data, \code{events_england.json}, included in this package is only
#'   a single game of events subsetted from the full publicly available
#'   Wyscout England event data.
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
#'
#' @examples
#' file_path <- system.file("extdata", "events_england.json", package = "scoutr")
#'
#' events <- read_events(file_path)
#' events_list <- read_events(file_path, tidy_tibble = FALSE)
#'
#' @import dplyr
#' @import purrr
#' @import tidyr
#' @importFrom jsonlite read_json fromJSON
#' @importFrom janitor clean_names
#' @importFrom rlang .data
#' @export

read_events <- function(file, tidy_tibble = TRUE, keep_tags = TRUE) {

  if (!tidy_tibble) {
    return(read_json(file))
  }

  step <- 1
  total_steps <- 2 + keep_tags
  msg <- "Reading JSON data and converting to tibble...\n"
  cat("  Step", paste0('(',step,'/',total_steps,'):'), msg)
  step <- step + 1

  # read data and clean names
  events <- fromJSON(file)
  events <- as_tibble(events) %>%
    clean_names()

  # fix tags
  if (keep_tags) {
    msg <- "Tidying tag variables...\n"
    cat("  Step", paste0('(',step,'/',total_steps,'):'), msg)
    step <- step + 1
    events <- events %>%
      mutate(row_id = 1:nrow(.)) %>%
      unnest(cols = .data$tags, names_sep = "_", keep_empty = TRUE) %>%
      mutate(tag_id_name = paste0("tag_id_", unlist(lapply(rle(.data$row_id)$lengths,
                                                          seq, from = 1)))) %>%
      pivot_wider(names_from = .data$tag_id_name, values_from = .data$tags_id) %>%
      select(-.data$row_id)
  } else {
    events <- events %>%
      select(-.data$tags)
  }

  # fix positions
  msg <- "Tidying event pitch locations...\n"
  cat("  Step", paste0('(',step,'/',total_steps,'):'), msg)
  events_temp <- events %>%
    mutate(row_id = 1:nrow(.)) %>%
    unnest(cols = .data$positions, keep_empty = TRUE) %>%
    mutate(loc_tag = paste0("loc_", unlist(lapply(rle(.data$row_id)$lengths,
                                                 seq, from = 1))))

  end_positions <- events_temp %>%
    filter(.data$loc_tag == "loc_2") %>%
    select(.data$y, .data$x, .data$row_id) %>%
    rename(end_y = .data$y, end_x = .data$x)

  events <- events_temp %>%
    filter(.data$loc_tag == "loc_1") %>%
    rename(start_y = .data$y, start_x = .data$x) %>%
    left_join(end_positions, by = "row_id")

  cat("  Happy scouting!\n\n")

  events %>%
    select(.data$id, .data$match_id, .data$match_period, .data$team_id,
           .data$event_id, .data$event_name,
           .data$sub_event_id, .data$sub_event_name, .data$player_id,
           .data$event_sec, .data$start_x, .data$start_y,
           .data$end_x, .data$end_y, contains("tag_id")) %>%
    mutate_at(vars(contains("id")), as.character)
}
