
<!-- README.md is generated from README.Rmd. Please edit that file -->

# scoutr <a href=''><img src='man/figures/logo.png' align="right" height="139" /></a>

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![R build
status](https://github.com/shawnsanto/scoutr/workflows/R-CMD-check/badge.svg)](https://github.com/shawnsanto/scoutr/actions)
<!-- badges: end -->

## Overview

A complete and consistent set of functions for reading, manipulating,
and visualizing Wyscout soccer data in R.

All public Wyscout data is available at
<https://figshare.com/collections/Soccer_match_event_dataset/4415000/2>

## Installation

The package is not available on CRAN, so please install the development
version.

``` r
# install.packages("devtools")
devtools::install_github("shawnsanto/scoutr")
```

## Usage

``` r
library(scoutr)
library(dplyr)

# read and preview some event data
events <- read_events(system.file("extdata", "events_england.json", package = "scoutr"))
#>   Step (1/3): Reading JSON data and converting to tibble...
#>   Step (2/3): Tidying tag variables...
#>   Step (3/3): Tidying event pitch locations...
#>   Happy scouting!

events %>%
  select(event_sec:end_y)
#> # A tibble: 1,768 x 5
#>   event_sec start_x start_y end_x end_y
#>       <dbl>   <int>   <int> <int> <int>
#> 1      2.76      49      49    31    78
#> 2      4.95      31      78    51    75
#> 3      6.54      51      75    35    71
#> 4      8.14      35      71    41    95
#> 5     10.3       41      95    72    88
#> # … with 1,763 more rows

# transform pitch locations
events %>%
  select(event_sec:end_y) %>%
  transform_locations(x = c("start_x", "end_x"), y = c("start_y", "end_y"),
                      dim = c(105, 70), units = "meters")
#>   Attributes added: 'units', 'pitch_dimensions'.
#>   Pitch dimensions: (105 X 70) meters
#> # A tibble: 1,768 x 5
#>   event_sec start_x start_y end_x end_y
#>       <dbl>   <dbl>   <dbl> <dbl> <dbl>
#> 1      2.76    51.4    34.3  32.6  54.6
#> 2      4.95    32.6    54.6  53.6  52.5
#> 3      6.54    53.6    52.5  36.8  49.7
#> 4      8.14    36.8    49.7  43.0  66.5
#> 5     10.3     43.0    66.5  75.6  61.6
#> # … with 1,763 more rows

# define possessions
events %>% 
  select(match_id, event_name, team_id) %>% 
  encode_possession_sequence(event_var = "event_name", team_var = "team_id") %>% 
  print(n = 20)
#> # A tibble: 1,768 x 5
#>    match_id event_name team_id possession_id possession_seq
#>    <chr>    <chr>      <chr>           <dbl>          <int>
#>  1 2499719  Pass       1609                1              1
#>  2 2499719  Pass       1609                1              2
#>  3 2499719  Pass       1609                1              3
#>  4 2499719  Pass       1609                1              4
#>  5 2499719  Pass       1609                1              5
#>  6 2499719  Pass       1609                1              6
#>  7 2499719  Pass       1631                2              1
#>  8 2499719  Duel       1631                2              2
#>  9 2499719  Duel       1609                2              3
#> 10 2499719  Pass       1609                3              1
#> 11 2499719  Pass       1609                3              2
#> 12 2499719  Pass       1609                3              3
#> 13 2499719  Duel       1631                3              4
#> 14 2499719  Duel       1609                3              5
#> 15 2499719  Pass       1609                3              6
#> 16 2499719  Pass       1631                4              1
#> 17 2499719  Pass       1631                4              2
#> 18 2499719  Pass       1631                4              3
#> 19 2499719  Pass       1631                4              4
#> 20 2499719  Pass       1631                4              5
#> # … with 1,748 more rows
```

## References

Pappalardo, L., Cintia, P., Rossi, A. et al. A public data set of
spatio-temporal match events in soccer competitions. Sci Data 6, 236
(2019). <https://doi.org/10.1038/s41597-019-0247-7>
