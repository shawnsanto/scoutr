#' Pitch themes
#'
#' These are template themes that can be matched (or not) with the
#' \code{palatte} argument in \code{fc_annotate_pitch()}. Use
#' \code{ggplot2} \code{theme()} for further theme refinements.
#'
#' @details
#' \describe{
#'
#' \item{`fc_theme_bw()`}{
#' A white pitch with black field markings.}
#'
#' \item{`fc_theme_classic()`}{
#' A grass-green pitch with white field markings.}
#'
#' \item{`fc_theme_dark()`}{
#' A black pitch with white field markings.}
#'
#' \item{`fc_theme_gw()`}{
#' A white pitch with grey field markings.}
#'
#' \item{`fc_theme_smurf()`}{
#' A blue pitch with white field markings. Inspired by the Boise State
#' football field in Idaho.}
#'
#' \item{`fc_theme_wc()`}{
#' Pitch and field markings representing the upcoming World Cup host's flag.
#' The 2022 World Cup is hosted by Qatar.}
#' }
#'
#' @references
#'   \emph{Pappalardo, L., Cintia, P., Rossi, A. et al. A public data
#'         set of spatio-temporal match events in soccer competitions. Sci
#'         Data 6, 236 (2019). \url{https://doi.org/10.1038/s41597-019-0247-7}}
#'
#'    All public Wyscout data is available at \url{https://figshare.com/collections/Soccer_match_event_dataset/4415000/2}
#'
#' @examples
#' # load ggplot2
#' library(ggplot2)
#'
#' ggplot() +
#'   fc_annotate_pitch() +
#'   fc_theme_gw()
#'
#' ggplot() +
#'   fc_annotate_pitch(palette = "smurf") +
#'   fc_theme_smurf()
#'
#' ggplot() +
#'   fc_annotate_pitch() +
#'   fc_theme_wc()
#'
#' @import ggplot2
#' @name fc_theme
#' @aliases NULL
NULL

#' @export
#' @rdname fc_theme
fc_theme_bw <- function() {
  theme_void() +
    theme(
      plot.background = element_rect(fill = "white", color = NA),
      aspect.ratio    = 70 / 105
    )
}

#' @export
#' @rdname fc_theme
fc_theme_classic <- function() {
  theme_void() +
    theme(
      plot.background = element_rect(fill = "#196f0c", color = NA),
      aspect.ratio    = 70 / 105
    )
}

#' @export
#' @rdname fc_theme
fc_theme_dark <- function() {
  theme_void() +
    theme(
      plot.background = element_rect(fill = "#130a06", color = NA),
      aspect.ratio    = 70 / 105
    )
}

#' @export
#' @rdname fc_theme
fc_theme_gw <- function() {
  theme_void() +
    theme(
      plot.background = element_rect(fill = "white", color = NA),
      aspect.ratio    = 70 / 105
    )
}

#' @export
#' @rdname fc_theme
fc_theme_smurf <- function() {
  theme_void() +
    theme(
      plot.background = element_rect(fill = "#0033A0", color = NA),
      aspect.ratio    = 70 / 105
    )
}

#' @export
#' @rdname fc_theme
fc_theme_wc <- function() {
  theme_void() +
    theme(
      plot.background = element_rect(fill = "#8d1b3d", color = NA),
      aspect.ratio    = 70 / 105
    )
}


