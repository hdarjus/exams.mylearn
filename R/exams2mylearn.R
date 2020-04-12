#' Exam Generation for the MyLearn Platform
#' 
#' The Vienna University of Economics and Business has a special
#' XML format on its teaching platform MyLearn. \code{exams2mylearn} transforms
#' input files in the R/exams to XML files and zips them. The resulting
#' zip file can be directly uploaded to the MyLearn platform after having
#' contected the MyLearn development team.
#' 
#' @param filename (character) absolute or relative path to the exercise template.
#' Usually simply a filename pointing at a .Rmd file in the working directory
#' @param name (character) unique name of output files
#' @param n (integer) number of random variants to create
#' @param dir (character, optional) output directory, defaults to the currect working directory
#' @return As a side effect, the function produces a zip file in the working
#' directory. The exact path to the zip file is returned invisibly.
#' @note The development team has to turn on the upload functionality on
#' a per course basis.
#' @export
exams2mylearn <- function (filename, name, n, dir = ".") {
  tmpdir <- base::tempdir()
  outdir <- base::normalizePath(dir, mustWork = FALSE)
  outfile <- base::file.path(outdir, glue::glue("{name}.zip"))
  
  if (base::file.exists(outfile)) {
    warning(outfile, " exists. Consider first deleting it or spedifying another 'name' parameter.")
  }
  
  template.path <- base::system.file("extdata", "template-multiple.xml", package = "exams.wuvienna")
  if (!base::file.exists(template.path)) {
    base::stop("Could not find template-multiple.xml. Looking for it under ", template.path, ".")
  } else {
    base::message("Necessary XML input file found")
    # Read the XML template
    template <- xml2::read_xml(template.path)
  }
  if (!base::dir.exists(outdir)) {
    base::dir.create(outdir)
    base::message("Created ", outdir)
  } else {
    base::message("Output directory ", outdir, " found")
  }
  base::message("Temporary directory is ", tmpdir)
  
  base::message("Step 1: Generating exams in HTML format...")
  # Generate exams both in R list and in .html
  xexm <- exams::exams2html(filename, name = glue::glue("{name}_v"), n = n,
                            dir = tmpdir, converter = "pandoc-mathjax")
  base::message("Step 1: Done")
  
  base::message("Step 2: Converting from HTML to XML\r\n", appendLF=FALSE)
  utils::flush.console()
  to_zip <- character(0)
  for (num in base::seq_len(n)) {
    svMisc::progress(num, max.value = n)
    # Extract current exercise in R list format
    exercise_exams <- xexm[[glue::glue("exam{stringr::str_pad(num, stringr::str_length(n), side = 'left', pad = '0')}")]]$exercise1
    # Read current exercise HTML as XML
    htmlobj <- xml2::read_html(file.path(tmpdir, glue::glue("{name}_v{num}.html")))
    
    # Copy template
    output <- xml2::xml_new_root(xml2::xml_root(template))
    
    # Add HTML nodes
    ## Replace title
    title_text <- exercise_exams$metainfo$name
    title_node_temp <- xml2::xml_find_first(output, "./exercise/metadata/title")
    xml2::xml_text(title_node_temp) <- title_text
    ## Replace question
    q_node_html <- xml2::xml_find_first(xml2::read_html(stringr::str_c("<span>", stringr::str_c(exercise_exams$question, collapse = "\n"), "</span>")), "./body/span")
    q_node <- xml2::xml_find_first(output, "./exercise/question_data/multiplechoice/problem_text")
    xml2::xml_add_child(q_node, q_node_html)
    ## Replace short name
    exercise_node <- xml2::xml_find_first(output, "./exercise")
    xml2::xml_attr(exercise_node, "shortname") <- glue::glue("{stringr::str_to_lower(stringr::str_replace_all(title_text, '[[:space:]]', ''))}{num}")
    ## Process answers options
    mult_node <- xml2::xml_find_first(output, "./exercise/question_data/multiplechoice")
    for (i in base::seq_along(exercise_exams$questionlist)) {
      # Create answer template node
      ans_node_temp <- xml2::read_xml(stringr::str_c('<answer value="', stringr::str_to_lower(exercise_exams$metainfo$solution[i]), '"> <answer_text/> </answer>'))
      # Construct answer html nodes
      ans_str <- exercise_exams$questionlist[i]
      ans_node_html <- xml2::xml_find_first(xml2::read_html(stringr::str_c("<p align=\"left\">", ans_str, "</p>")), "./body/p")
      xml2::xml_add_child(mult_node, ans_node_temp,
                    .where = base::length(xml2::xml_children(mult_node))-1)
      ans_node <- xml2::xml_find_first(output, glue::glue("./exercise/question_data/multiplechoice/answer[{i}]/answer_text"))
      xml2::xml_add_child(ans_node, ans_node_html)
    }
    feedback_node <- xml2::xml_find_first(output, "./exercise/question_data/multiplechoice/feedback")
    feedback_node_html <- xml2::xml_find_first(xml2::read_html(stringr::str_c("<span>", stringr::str_c(exercise_exams$solution, collapse = "\n"), "</span>")), "./body/span")
    xml2::xml_add_child(feedback_node, feedback_node_html)
    
    fileout <- base::file.path(tmpdir, glue::glue("{name}_v{num}.xml"))
    xml2::write_xml(output, fileout)
    to_zip <- c(to_zip, fileout)
  }
  base::message("\nStep 2: Done")
  
  base::message("Step 3: Writing ZIP file")
  utils::zip(outfile, to_zip, flags = "-Dj9X")
  base::message("Step 3: Done. Output is ", outfile)
  base::invisible(outfile)
}

