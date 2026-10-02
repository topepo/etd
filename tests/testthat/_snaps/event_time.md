# event_time() validates inputs

    Code
      event_time("a", "e")
    Condition
      Error in `event_time()`:
      ! Can't convert `time` <character> to <double>.
    Code
      event_time(1, 1)
    Condition
      Error in `event_time()`:
      ! `status` must be a character vector, not a number.
    Code
      event_time(1:2, "e")
    Condition
      Error in `event_time()`:
      ! `status` must have length 2 (the length of `time`), not 1.
    Code
      event_time(1, "e", c(NA, NA))
    Condition
      Error in `event_time()`:
      ! `time_max` must have length 1 (the length of `time`), not 2.
    Code
      event_time(c(-1, -2), c("e", "e"))
    Condition
      Error in `event_time()`:
      ! `time` must be non-negative. Problem at locations 1 and 2.
    Code
      event_time(c(1, 2, 3), c("e", NA, NA))
    Condition
      Error in `event_time()`:
      ! `status` must not be missing when `time` is not missing. Problem at locations 2 and 3.
    Code
      event_time(1, "x")
    Condition
      Error in `event_time()`:
      ! `status` must be one of "e", "r", "l", and "i".
      x Problem at location 1.
    Code
      event_time(1, "e", 3)
    Condition
      Error in `event_time()`:
      ! `time_max` must be missing for values that are not interval censored. Problem at location 1.
    Code
      event_time(1, "i")
    Condition
      Error in `event_time()`:
      ! `time_max` must not be missing for interval-censored values. Problem at location 1.
    Code
      event_time(c(5, 1), c("i", "i"), c(4, 3))
    Condition
      Error in `event_time()`:
      ! `time` must be smaller than `time_max` for interval-censored values. Problem at location 1.

# event_time() errors use the supplied call

    Code
      wrapper(1, "x")
    Condition
      Error in `wrapper()`:
      ! `status` must be one of "e", "r", "l", and "i".
      x Problem at location 1.

# new_event_time() checks types

    Code
      new_event_time(1, "e")
    Condition
      Error in `new_event_time()`:
      ! `time` must be a list, not a number.
    Code
      new_event_time(list(1), 1)
    Condition
      Error in `new_event_time()`:
      ! `status` must be a character vector, not a number.

# event_time vectors print

    Code
      x
    Output
      <event_time[5]>
      [1] 7      5+     3-     [2, 4] <NA>  
    Code
      event_time(double(), character())
    Output
      <event_time[0]>

# event_time vectors print in tibbles

    Code
      tibble::tibble(x = x)
    Output
      # A tibble: 3 x 1
             x
        <evtm>
      1     7 
      2     5+
      3 [2, 4]
    Code
      tibble::tibble(x = list(x, x[1]))
    Output
      # A tibble: 2 x 1
        x         
        <list>    
      1 <evtm [3]>
      2 <evtm [1]>

# tibble columns use pillar's significant digits

    Code
      tibble::tibble(x = x)
    Output
      # A tibble: 6 x 1
               x
          <evtm>
      1   0     
      2   0.397-
      3   2.98+ 
      4   1.23+ 
      5       NA
      6 [2.5, 4]
    Code
      withr::with_options(list(pillar.sigfig = 5), print(tibble::tibble(x = x)))
    Output
      # A tibble: 6 x 1
               x
          <evtm>
      1  0      
      2  0.397- 
      3  2.983+ 
      4  1.2346+
      5       NA
      6 [2.5, 4]

