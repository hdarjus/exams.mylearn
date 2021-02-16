#' Question Generation in the 'MyLearn' XML Format
#'
#' Randomized multiple-select and single-select
#' question generation for the 'MyLearn' platform. Question templates
#' in the form of the R/exams package
#' are transformed into XML format required by 'MyLearn'.
#'
#' @name exams.mylearn-package
#' @aliases exams.mylearn
#' @docType package
#' @importFrom exams exams2html
#' @importFrom xml2 read_xml read_html xml_validate xml_attrs xml_find_first xml_find_all xml_text xml_replace xml_attr xml_add_child xml_children write_xml
#' @importFrom glue glue
#' @importFrom stringr str_to_lower str_pad str_length str_replace_all str_c
#' @importFrom stringi stri_unescape_unicode
#' @importFrom utils zip
#' @importFrom tools file_path_as_absolute file_path_sans_ext file_ext
#' @importFrom pkgbuild has_build_tools
NULL
