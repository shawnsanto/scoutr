#' Compute velocity within a grid of polygons
#'
#' This function computes summary statistics of velocities within a grid of
#' polygons that cover the pitch dimensions
#'
#' @param data A simple feature object. Event velocities should be variables in
#'   \code{data} as computed from function \code{fc_velocity_event()}.
#' @param metric A character vector of length one indicating which polygon
#'   velocity to compute. Should be one of "speed", "east_velocity",
#'   "west_velocity", "north_velocity", "south_velocity", "east_west_velocity",
#'   "north_south_velocity".
#' @param match A character vector of match id values. Only required to define
#'   possession ids and sequences in multi-match data frames.
#' @param fcn A summary function as a character vector. Typical values are
#'   "mean", "median", "sd", "IQR".
#' @param ... Arguments and their values related to \code{fcn}.
#' @param shape A character vector of length one indicating the polygon type.
#'   Valid values include "square" and "hexagon".
#' @param size A numeric vector of length one defining the size of the polygons
#' @param preview_grid A logical vector of length one. A value of \code{TRUE} will
#'   show the partitioned pitch according to the specified polygons.
#'
#' @return A simple feature object with a \code{geometry} and summary statistic
#'   as defined by arguments \code{fcn} and \code{metric}.
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
#' file_path <- system.file("extdata", "events_england.json", package = "scoutr")
#' events <- fc_read_events(file_path)
#'
#' data <- events %>%
#'   select(-starts_with("tag_")) %>%
#'   fc_locations_transform(x = c("start_x", "end_x"), y = c("start_y", "end_y")) %>%
#'   fc_sequence_possession(event_var = "event_name", team_var = "team_id") %>%
#'   fc_velocity_event(start_loc = c("start_x", "start_y"), end_loc = c("end_x", "end_y")) %>%
#'   fc_locations_link(start_loc = c("start_x", "start_y"), end_loc = c("end_x", "end_y"))
#'
#'
#' fc_velocity_polygon(data, metric = "east_west_velocity", shape = "hexagon",
#'                     fcn = "median", na.rm = TRUE, size = 6,
#'                     preview_grid = TRUE)
#'
#' fc_velocity_polygon(data, metric = "speed", size = 5, shape = "square",
#'                     fcn = "mean", na.rm = TRUE, preview_grid = TRUE)
#'
#' fc_velocity_polygon(data, metric = "north_south_velocity",
#'                     size = 5, shape = "square",
#'                     fcn = "median", na.rm = TRUE, preview_grid = FALSE)
#'
#' @import dplyr
#' @import purrr
#' @import sf
#' @import ggplot2
#' @export

fc_velocity_polygon <- function(data, metric, match = NULL, fcn = "median", ...,
                                shape = "square", size = 5,
                                preview_grid = FALSE) {

  if (!is.null(match)) {
    data <- data %>%
      filter(.data$match_id == match)
  }

  square_flag <- TRUE
  if (shape == "hexagon") {square_flag <- FALSE}

  # define grid based on parameter values
  polygon_grid <- st_make_grid(data, cellsize = size, what = "polygons",
                               square = square_flag) %>%
    as_tibble() %>%
    st_as_sf()

  # visualize grid if desired
  if (preview_grid) {

    polygon_grid_plot <- ggplot(polygon_grid) +
      geom_sf(fill = "lightgreen", color = "grey60") +
      geom_sf_text(aes(label = row.names(polygon_grid)), size = 2) +
      theme_void()

    print(polygon_grid_plot)
  }

  # compute intersections for passes that intersect with polygons
  intersections <- st_intersects(data$geometry, polygon_grid)


  # assign velocities to correct polygons
  velocity_list <<- vector(mode = "list", length = nrow(polygon_grid))

  add_velocity <- function(event) {
    intersections[[event]] %>%
      walk(~(velocity_list[[.]] <<- append(velocity_list[[.]], data[event, metric,
                                                                    drop = TRUE])))
  }

  walk(seq(nrow(data)), add_velocity)

  velocity_list <- modify_if(velocity_list, is.null, ~NA)

  var_name <- paste0(fcn, "_", metric)
  polygon_grid[[var_name]] <- map_dbl(velocity_list, get(fcn), ...)
  polygon_grid
}
