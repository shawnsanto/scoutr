
<!-- README.md is generated from README.Rmd. Please edit that file -->

# scoutr <a href=''><img src='man/figures/logo.png' align="right" height="139" /></a>

<!-- badges: start -->

![GitHub R package
version](https://img.shields.io/github/r-package/v/shawnsanto/scoutr?style=for-the-badge)
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

read_events(system.file("extdata", "events_england.json", package = "scoutr"))
#>   Step (1/3): Reading JSON data and converting to tibble...
#>   Step (2/3): Tidying tag variables...
#>   Step (3/3): Tidying event pitch locations...
#>   Happy scouting!
#> # A tibble: 1,768 x 19
#>   id    match_id match_period team_id event_id event_name sub_event_id
#>   <chr> <chr>    <chr>        <chr>   <chr>    <chr>      <chr>       
#> 1 1779… 2499719  1H           1609    8        Pass       85          
#> 2 1779… 2499719  1H           1609    8        Pass       83          
#> 3 1779… 2499719  1H           1609    8        Pass       82          
#> 4 1779… 2499719  1H           1609    8        Pass       82          
#> 5 1779… 2499719  1H           1609    8        Pass       85          
#> # … with 1,763 more rows, and 12 more variables: sub_event_name <chr>,
#> #   player_id <chr>, event_sec <dbl>, start_x <int>, start_y <int>,
#> #   end_x <int>, end_y <int>, tag_id_1 <chr>, tag_id_2 <chr>, tag_id_3 <chr>,
#> #   tag_id_4 <chr>, tag_id_5 <chr>

read_teams(system.file("extdata", "teams.json", package = "scoutr"))
#> # A tibble: 142 x 9
#>   wy_id official_name name  area_name city  area_id area_alpha_2 area_alpha_3
#>   <chr> <chr>         <chr> <chr>     <chr> <chr>   <chr>        <chr>       
#> 1 1613  "Newcastle U… "New… England   Newc… 0       ""           XEN         
#> 2 692   "Real Club C… "Cel… Spain     Vigo  724     "ES"         ESP         
#> 3 691   "Reial Club … "Esp… Spain     Barc… 724     "ES"         ESP         
#> 4 696   "Deportivo A… "Dep… Spain     Vito… 724     "ES"         ESP         
#> 5 695   "Levante UD"  "Lev… Spain     Vale… 724     "ES"         ESP         
#> # … with 137 more rows, and 1 more variable: type <chr>
```

## References

Pappalardo, L., Cintia, P., Rossi, A. et al. A public data set of
spatio-temporal match events in soccer competitions. Sci Data 6, 236
(2019). <https://doi.org/10.1038/s41597-019-0247-7>
