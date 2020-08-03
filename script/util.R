
# Metrics calculation -----------------------------------------------------
# normalized rmse
rmse <- function(pred, obs, na.rm = TRUE) {
  caret::RMSE(pred, obs, na.rm = na.rm) / mean(obs, na.rm = na.rm)
}

smape <- function(pred, obs, na.rm = TRUE, ...) {
  pe <- (abs(pred-obs)) / ((abs(pred) + abs(obs))/2)
  pe <- ifelse(obs == 0 & pred == 0, 0, pe)
  mean(pe, na.rm = na.rm, ...)
}

mae <- function(pred, obs, na.rm = TRUE, ...) {
  ae = (abs(pred-obs))
  mean(ae, na.rm = na.rm, ...)
}

mase <- function(pred, obs, insample, na.rm = TRUE, ...) {
  abs(pred-obs) / mean(abs(diff(insample)), ...)
}


# CV Block ----------------------------------------------------------------
get_cv_block <- function(include_train = FALSE) {
  ret <- data_frame(
    cat = c("CV1", "CV1.1",
            "CV2", "CV2.1",
            "CV3", "CV3.1",
            "CV4", "CV5", "Private"),
    start = c(seq(42+1, 36+1, -1), 33+1, 45+1)
  ) %>%
    mutate(end = start + 3-1)
  if(include_train == FALSE) {
    ret <- ret %>%
      filter(start != 45+1)
  }
  ret
}



