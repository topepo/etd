# as_surv() errors for unsupported inputs

    Code
      as_surv(1)
    Condition
      Error in `as_surv()`:
      ! Can't convert a number to a <Surv> object.
    Code
      as_surv(x, 2)
    Condition
      Error in `as_surv()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = 2
      i Did you forget to name an argument?

