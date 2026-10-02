
<!-- README.md is generated from README.Rmd. Please edit that file -->

# etd

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The data structure for potentially censored data in the survival package
has served the community well. However, it was created in the mid 1980’s
for the S language.

etd (Event Time Data) proposes a data structure that:

- Is an R vctrs class (not a matrix)
- Has more obvious status values (descriptive letters instead of integer
  codes)
- Can easily accommodate different types of censoring.

## Installation

You can install the development version of etd like so:

``` r
pak::pak("topepo/etd)
```

## Examples

Suppose we have data with complete event times as well as left\_ and
right censored data:

``` r
set.seed(1)
observed_times <- sort(rexp(5))
status <- c("left censored", rep("event", 3), "right censored")
```

With etd, the `event_time()` function takes the time values as is and
uses status values of “e” (events), “l” (left censored), “r” (right
censored), or “i” (interval censored).

``` r
library(etd)

etd_obj <- event_time(observed_times, substr(status, 1, 1))
etd_obj
#> <event_time[5]>
#> [1] 0.1397953- 0.1457067  0.4360686  0.7551818  1.1816428+
is.matrix(etd_obj)
#> [1] FALSE

# Add to a data frame: 
etd_df <- data.frame(times = etd_obj)
etd_df
#>        times
#> 1 0.1397953-
#> 2 0.1457067 
#> 3 0.4360686 
#> 4 0.7551818 
#> 5 1.1816428+
```

When there are interval censored values in the data, the `time_max`
argument is used. Here, `time` specifies the shorter duration and
`time_max` is for the longer times. Suppose the first value i n our data
was also right censored at 1.5:

``` r
int_obj <- event_time(observed_times,
                      status = c("i", "e", "e", "e", "r"),
                      time_max = c(1.5, rep(NA_real_, 4)))
int_obj
#> <event_time[5]>
#> [1] [0.1397953, 1.5000000] 0.1457067              0.4360686             
#> [4] 0.7551818              1.1816428+
is.matrix(int_obj)
#> [1] FALSE
```

To extract the individual components, there are extractor functions:

``` r
extract_time(etd_obj)
#> [1] 0.1397953 0.1457067 0.4360686 0.7551818 1.1816428
extract_status(etd_obj)
#> [1] "l" "e" "e" "e" "r"
```

and there are also conversion functions:

``` r
as_surv(etd_obj)
#> [1] 0.1397953- 0.1457067  0.4360686  0.7551818  1.1816428+
as_tibble(etd_obj)
#> # A tibble: 5 × 3
#>    time status time_max
#>   <dbl> <chr>     <dbl>
#> 1 0.140 l            NA
#> 2 0.146 e            NA
#> 3 0.436 e            NA
#> 4 0.755 e            NA
#> 5 1.18  r            NA
```
