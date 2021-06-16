#' Read a set of Lighthouse report files as a data frame
#' @param files A character vector of basenames for files.
#' @param count The number of files of each basename.
#' @param bust Whether to also generate the names for cache-busted results
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @export
read_lighthouse_json <- function(files, count, bust=FALSE) {
  patterns <- tibble::tibble(
    files=purrr::cross3(files, seq(count), if(bust) c("", "Bust") else c(""))
  )
  data <- patterns %>%
    hoist_parts(bust) %>%
    dplyr::mutate(
      filename=purrr::map_chr(files, ~stringr::str_c(.x[[1]], .x[[3]], "_", .x[[2]], ".json")),
      treatment=purrr::map_chr(files, ~stringr::str_c(.x[[1]], .x[[3]])),
    ) %>%
    dplyr::mutate(files=purrr::map(.data$filename, ~jsonlite::read_json(.x)))
  data %>%
    dplyr::mutate(
      metrics=purrr::map(files, ~.x$audits$metrics$details$items[[1]] %>% tibble::enframe()),
      network=purrr::map(files, ~.x$audits[["network-requests"]]$details$items %>% tibble::enframe()),
      frames=purrr::map(files, ~.x$audits[["screenshot-thumbnails"]]$details$items %>% tibble::enframe())
    ) %>%
    tidyr::unnest(.data$metrics) %>%
    dplyr::mutate(value=purrr::flatten_dbl(.data$value)) %>%
    tidyr::pivot_wider(names_from = .data$name, values_from=.data$value)
}

hoist_parts <- function(patterns, bust) {
  if(bust) {
    patterns %>%
      tidyr::hoist(.data$files, env=1, run=2, bust=3, .remove=FALSE) %>%
      mutate(bust=bust == "Bust")
  } else {
    patterns %>% tidyr::hoist(.data$files, env=1, run=2, .remove=FALSE)
  }
}
