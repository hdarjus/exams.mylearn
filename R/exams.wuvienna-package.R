#' Question Generation in the MyLearn XML Format
#' 
#' Randomized multiple-select and single-select
#' question generation for the MyLearn platform at the Vienna
#' University of Economics and Business. Question templates
#' in the form of the R/exams package
#' are transformed into MyLearn's XML format.
#' 
#' @name exams.wuvienna-package
#' @aliases exams.wuvienna
#' @docType package
#' @importFrom exams exams2html
#' @importFrom xml2 read_xml read_html xml_validate xml_attrs xml_find_first xml_find_all xml_text xml_replace xml_attr xml_add_child xml_children write_xml
#' @importFrom glue glue
#' @importFrom stringr str_to_lower str_pad str_length str_replace_all
#' @importFrom utils zip
NULL
