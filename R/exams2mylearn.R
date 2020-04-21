#' Exam Generation for the 'MyLearn' Platform
#' 
#' The Vienna University of Economics and Business has a special
#' XML format on its teaching platform 'MyLearn'. \code{exams2mylearn} transforms
#' input files in the R/exams format to XML files and zips them. The resulting
#' zip file can be directly uploaded to the 'MyLearn' platform after having
#' contacted the 'MyLearn' development team.
#' 
#' @param filename (character) absolute or relative path to the exercise template.
#' Usually simply a filename pointing at a .Rmd file in the working directory
#' @param n (integer) number of random variants to create
#' @param dir (character) output directory, will be created if non-existent
#' @param name (character, optional) unique name prefix of temporary and output files,
#' defaults to \code{filename} withour the non-alphabetic characters
#' @param outfile (character, optional) output filename (not a path), defaults to \code{name}.zip
#' @param dontask (logical, optional) if \code{TRUE} and the output zip file exists then
#' @param distort.shortname (logical, optional) should the shortname include a random ending?
#' Defaults to \code{FALSE}
#' @param ... forwarded to \code{exams2html}
#' @return As a side effect, the function produces a zip file in directory \code{dir}.
#' If \code{dir} is invalid or unspecified, the function returns with an error.
#' The exact path to the zip file is returned invisibly.
#' @note The development team has to turn on the upload functionality on
#' a per course basis.
#' @examples
#' \dontrun{
#' ex_files <- example_paths()
#' exams2mylearn(ex_files["plot"], 40, dir = ".",
#'               outfile = "final_exam.zip",
#'               distort.shortname = TRUE)
#' exams2mylearn(ex_files["single_choice"], 500, dir = ".", verbose = TRUE)
#' }
#' @export
exams2mylearn <- function (filename, n, dir, name = NULL, outfile = NULL,
                           dontask = !base::interactive(),
                           distort.shortname = FALSE, ...) {
  if (base::missing(name) || base::is.null(name)) {
    name <- stringr::str_to_lower(stringr::str_replace_all(filename, '[^[:alnum:]]', ''))
  } else if (!base::is.character(name) || base::length(name) != 1L) {
    base::stop("Parameter 'name' has to a character string")
  }
  tmpdir <- base::tempdir()
  if (!base::dir.exists(dir)) {
    base::warning("Creting new directory", dir)
    base::dir.create(dir, showWarnings = FALSE, recursive = TRUE)
    if (!base::dir.exists(dir)) {
      base::stop("Unable to create", dir)
    }
  }
  outdir <- tools::file_path_as_absolute(dir)
  if (base::missing(outfile) || base::is.null(outfile)) {
    outfile <- base::file.path(outdir, glue::glue("{name}.zip"))
  } else if (outfile != base::basename(outfile)) {
    base::stop("Parameter 'outfile' should be a file name without a file path")
  }
  if (base::file.exists(outfile) && !dontask) {
    input <- base::readline(base::paste(outfile, "exists. Are you sure you want to modify it? (Y/n) "))
    if (stringr::str_length(input) > 0L && !(stringr::str_to_lower(input) %in% base::c("y", "yes"))) {
      base::message("Finishing...")
      base::return()
    }
  }
  shortname_ending <- if (base::isTRUE(distort.shortname)) {
    stringr::str_c(base::sample(base::LETTERS, 8), collapse = "")
  } else {
    ""
  }
  
  template.path <- base::c(
    "multiplechoice" = system.file("extdata", "template-multiple.xml", package = "exams.wuvienna"),
    "singleanswer" = system.file("extdata", "template-single.xml", package = "exams.wuvienna")
    )
  if (!base::file.exists(template.path["singleanswer"]) ||
      !base::file.exists(template.path["multiplechoice"])) {
    base::stop("Could not find the template XML files. Searched for ",
               template.path["singleanswer"],
               " and ",
               template.path["multiplechoice"],
               ".")
  } else {
    base::message("Necessary XML input files found")
  }
  if (!base::dir.exists(outdir)) {
    base::dir.create(outdir)
    base::message("Created ", outdir)
  } else {
    base::message("Output directory ", outdir, " found")
  }
  base::message("Temporary directory is ", tmpdir)
  
  # Handle special characters
  special_character_codes <- base::c("00c4", "00d6", "00dc", "00df", "00e4", "00f6", "00fc")
  special_characters <- stringi::stri_unescape_unicode(stringr::str_c("\\u", special_character_codes, sep = ""))
  codes <- base::as.integer(base::as.hexmode(special_character_codes))
  placeholder <- "JJJ11111EIRRAAOOSDFKLJWE91AAAAVVA33SDPPOIDI111DIWEOROFJJSJS444DFLDKKS4L"
  html_codes <- stringr::str_c(placeholder, "#", codes, ";")
  base::names(html_codes) <- special_characters
  content <- base::readLines(filename, encoding = "UTF-8")
  content <- base::enc2utf8(content)
  for (sp_char in base::names(html_codes)) {
    content <- stringr::str_replace_all(content, sp_char, html_codes[sp_char])
  }
  modified_filename <- base::tempfile(pattern = tools::file_path_sans_ext(base::basename(filename)),
                                      tmpdir = tmpdir,
                                      fileext = stringr::str_c(".", tools::file_ext(filename)))
  base::writeLines(content, modified_filename, useBytes = TRUE)
  
  # Generate exams both in R list and in .html
  base::message("Step 1: Generating exams in HTML format...")
  xexm <- exams::exams2html(modified_filename,
                            name = glue::glue("{name}_v"), n = n,
                            dir = tmpdir, converter = "pandoc-mathjax",
                            encoding = "UTF-8", ...)
  base::message("Step 1: Done")
  
  base::message("Step 2: Converting from HTML to XML\r\n", appendLF=FALSE)
  
  # Single or multiple choice?
  single_choice <- xexm[[1]][[1]]$metainfo$type == "schoice"
  multiple_choice <- xexm[[1]][[1]]$metainfo$type == "mchoice"
  if (!base::xor(single_choice, multiple_choice)) {
    base::stop("Unknown exercise type. Only single choice (schoice) and multiple choice (mchoice) are allowed!")
  }
  type <- if (single_choice) "singleanswer" else "multiplechoice"
  # Read the XML template
  template <- xml2::read_xml(template.path[type], encoding = "UTF-8")
  to_zip <- base::character(0)
  for (num in base::seq_len(n)) {
    # Extract current exercise in R list format
    exercise_exams <- xexm[[stringr::str_c("exam", stringr::str_pad(num, stringr::str_length(n), side = 'left', pad = '0'))]]$exercise1
    exercise_exams$question <- stringr::str_replace_all(exercise_exams$question, placeholder, "&")
    exercise_exams$questionlist <- stringr::str_replace_all(exercise_exams$questionlist, placeholder, "&")
    exercise_exams$solution <- stringr::str_replace_all(exercise_exams$solution, placeholder, "&")
    exercise_exams$metainfo$name <- stringr::str_replace_all(exercise_exams$metainfo$name, placeholder, "&")
    
    # Copy template
    output <- xml2::xml_new_root(xml2::xml_root(template))
    
    # Add HTML nodes
    ## Replace title
    title_text <- exercise_exams$metainfo$name
    title_node_temp <- xml2::xml_find_first(output, "./exercise/metadata/title")
    xml2::xml_text(title_node_temp) <- title_text
    ## Replace question
    q_node_html <- xml2::read_xml(stringr::str_c("<span>", stringr::str_c(exercise_exams$question, collapse = "\n"), "</span>"))
    q_node <- xml2::xml_find_first(output, glue::glue("./exercise/question_data/{type}/problem_text"))
    xml2::xml_add_child(q_node, q_node_html)
    ## Replace shortname
    exercise_node <- xml2::xml_find_first(output, "./exercise")
    xml2::xml_attr(exercise_node, "shortname") <- stringr::str_c(stringr::str_to_lower(stringr::str_replace_all(title_text, '[[:space:]]', '')),
                                                                 stringr::str_to_lower(stringr::str_replace_all(filename, '[^[:alnum:]]', '')),
                                                                 shortname_ending,
                                                                 num,
                                                                 sep = "_")
    ## Process answers options
    mult_node <- xml2::xml_find_first(output, glue::glue("./exercise/question_data/{type}"))
    for (i in base::seq_along(exercise_exams$questionlist)) {
      # Create answer template node
      ans_node_temp <- xml2::read_xml(stringr::str_c('<answer value="', stringr::str_to_lower(exercise_exams$metainfo$solution[i]), '"> <answer_text/> </answer>'))
      # Construct answer html nodes
      ans_str <- exercise_exams$questionlist[i]
      ans_node_html <- xml2::read_xml(stringr::str_c("<p align=\"left\">", ans_str, "</p>"))
      xml2::xml_add_child(mult_node, ans_node_temp,
                    .where = base::length(xml2::xml_children(mult_node))-1)
      ans_node <- xml2::xml_find_first(output, glue::glue("./exercise/question_data/{type}/answer[{i}]/answer_text"))
      xml2::xml_add_child(ans_node, ans_node_html)
    }
    feedback_node <- xml2::xml_find_first(output, glue::glue("./exercise/question_data/{type}/feedback"))
    feedback_node_html <- xml2::read_xml(stringr::str_c("<span>", stringr::str_c(exercise_exams$solution, collapse = "\n"), "</span>"))
    xml2::xml_add_child(feedback_node, feedback_node_html)
    
    fileout <- base::file.path(tmpdir, glue::glue("{name}_v{num}.xml"))
    xml2::write_xml(output, fileout, encoding = "UTF-8")
    to_zip <- c(to_zip, fileout)
  }
  base::message("\nStep 2: Done")
  
  base::message("Step 3: Writing ZIP file")
  utils::zip(outfile, to_zip, flags = "-Dj9X")
  base::message("Step 3: Done. Output is ", outfile)
  base::invisible(outfile)
}

