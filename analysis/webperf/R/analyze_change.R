#' Analyze a tibble of Lighthouse data
#' @param specs A tibble of data, such as the one loaded by `read_lighthouse_json`.
#' @param variable The name of a column from `specs` to analyze
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @export
analyze_change <- function(specs, variable) {
  variable <- rlang::ensym(variable)
  formula <- rlang::new_formula(variable, quote(treatment))
  plot <- specs %>%
    ggplot2::ggplot(ggplot2::aes(!!variable, .data$treatment)) + ggplot2::geom_boxplot() + ggplot2::expand_limits(y=0)
  print(plot)
  test <- stats::t.test(formula, data=specs)
  sd_lcp <- effectsize::sd_pooled(formula, data=specs)
  power <- stats::power.t.test(NULL, diff(test$estimate)[[1]], sd_lcp, .05, .95,
                        type = "two.sample",
                        alternative = "two.sided",
  )
  print(test)
  print(power)
}
