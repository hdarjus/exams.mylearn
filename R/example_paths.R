#' Paths to Examples
#' 
#' @return Named sequence of characters. Each character string points
#' at an example file in the package.
#' @export
example_paths <- function () {
  c(
    "bullet_points" = base::system.file("extdata", "bullet-points.Rmd", package = "exams.wuvienna"),
    "mixture" = base::system.file("extdata", "everything.Rmd", package = "exams.wuvienna"),
    "plot" = base::system.file("extdata", "plot.Rmd", package = "exams.wuvienna"),
    "R_code" = base::system.file("extdata", "R-code.Rmd", package = "exams.wuvienna"),
    "R_output" = base::system.file("extdata", "R-output.Rmd", package = "exams.wuvienna"),
    "R_table" = base::system.file("extdata", "R-table.Rmd", package = "exams.wuvienna"),
    "single_choice" = base::system.file("extdata", "single-choice.Rmd", package = "exams.wuvienna")
  )
}