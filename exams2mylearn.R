needed.libraries <- c("exams", "xml2", "glue", "stringr", "svMisc")
for (libr in needed.libraries) {
  if (!require(libr, character.only = TRUE, quietly = TRUE)) {
    message("Installing package '", libr, "'")
    install.packages(libr, quiet = TRUE)
    library(libr, character.only = TRUE)
  }
}

exams2mylearn <- function (filename, name, n, curdir = getwd()) {
  tmpdir <- tempdir()
  indir <- file.path(curdir, "in")  # input directory, no need to touch it :)
  outdir <- file.path(curdir, "out")  # output directory
  
  schema.path <- file.path(indir, "learn-msq.xsd")
  template.path <- file.path(indir, glue("template.xml"))
  if (!file.exists(indir)) {
    stop("Could not find directory 'in'. Looking for it under ", indir, ".")
  }
  if (!file.exists(schema.path) || !file.exists(template.path)) {
    stop("Could not find the schema and the template in directory 'in'. Looking for them under ", schema.path, " and ", template.path, ".")
  } else {
    message("All necessary XML input files found")
  }
  if (!dir.exists(outdir)) {
    dir.create(outdir)
    message("Created", outdir, "\n")
  } else if (length(list.files(outdir)) != 0) {
    stop("Please empty or delete ", outdir, " and restart :)")
  } else {
    message("Output directory", outdir, "found")
  }
  message("Temporary directory is", tmpdir)
  
  message("Step 1: Generating exams in HTML format...")
  # Generate exams both in R list and in .html
  xexm <- exams2pandoc(filename, name = glue("{name}_v"), n = n,
                       dir = tmpdir, type = "html",
                       options = c("--standalone", "--mathjax"),
                       template = "plain.tex")
  message("Step 1: Done")
  # Read the XML Schema for validation (it's unneeded atually)
  schema <- read_xml(schema.path)
  
  message("Step 2: Converting from HTML to XML")
  for (num in seq_len(n)) {
    progress(num, max.value = n)
    # Extract current exercise in R list format
    exercise_exams <- xexm[[glue("exam{str_pad(num, str_length(n), side = 'left', pad = '0')}")]]$exercise1
    # Read current exercise HTML as XML
    htmlobj <- read_html(file.path(tmpdir, glue("{name}_v{num}.html")))
    # Some necessary fixes
    lapply(xml_find_all(htmlobj, ".//span"), function (x) xml_attr(x, "class") <- "math-tex")
    xml_remove(xml_find_all(htmlobj, "./body/ol/li/p/strong"))
    xml_remove(xml_find_all(htmlobj, "./body/ol/li/p/br"))
    xml_remove(xml_find_all(htmlobj, "./body/ol/li/p[not(boolean(text()))]"))
    begin_q_text_node <- xml_find_first(htmlobj, "./body/ol/li/p[1]/text()")
    xml_text(begin_q_text_node) <- str_replace(xml_text(begin_q_text_node), "\n", "")
    begin_sol_text_node <- xml_find_first(htmlobj, "./body/ol/li/p[2]/text()")
    xml_text(begin_sol_text_node) <- str_replace(xml_text(begin_sol_text_node), "\n", "")
    
    # Read the XML template
    output <- read_xml(template.path)
    # Validate the output in the beginning (this tests the xml2 package as well)
    if (!isTRUE(xml_validate(output, schema)))
      stop("Validation error!")
    # Remove namespaces, Learn doesn't like them
    xml_attrs(output) <- NULL
    # Extract an answer template node then delete them
    ans_node_temp <- xml_find_first(output, "./exercise/question_data/multiplechoice/answer")
    xml_remove(xml_find_all(output, "./exercise/question_data/multiplechoice/answer"))
    
    # Replace nodes
    ## Replace title
    title_text <- exercise_exams$metainfo$name
    title_node_temp <- xml_find_first(output, "./exercise/metadata/title")
    xml_text(title_node_temp) <- title_text
    ## Replace question
    q_node_html <- xml_find_first(htmlobj, "./body/ol/li/p")
    q_node_temp <- xml_find_first(output, "./exercise/question_data/multiplechoice/problem_text/p")
    xml_replace(q_node_temp, q_node_html)
    ## Replace short name
    ex_node_temp <- xml_find_first(output, "./exercise")
    xml_attr(ex_node_temp, "shortname") <- glue("{str_to_lower(str_replace_all(title_text, '[[:space:]]', ''))}{num}")
    ## Process answers options
    ans_nodes_html <- xml_find_all(htmlobj, "./body/ol/li/ol[1]/li/p")
    mult_node_temp <- xml_find_first(output, "./exercise/question_data/multiplechoice")
    for (i in seq_along(ans_nodes_html)) {
      xml_add_child(mult_node_temp, ans_node_temp,
                    .where = length(xml_children(mult_node_temp))-1)
      ans_node_temp_tomodify <- xml_find_first(output, glue("./exercise/question_data/multiplechoice/answer[{i}]"))
      xml_attr(ans_node_temp_tomodify, "value") <- str_to_lower(exercise_exams$metainfo$solution[i])
      p_node_temp_tomodify <- xml_find_first(output, glue("./exercise/question_data/multiplechoice/answer[{i}]/answer_text/p"))
      xml_replace(p_node_temp_tomodify, ans_nodes_html[[i]])
      p_node_temp_modified <- xml_find_first(output, glue("./exercise/question_data/multiplechoice/answer[{i}]/answer_text/p"))
      xml_attr(p_node_temp_modified, "align") <- "left"
    }
    p_node_temp <- xml_find_first(output, "./exercise/question_data/multiplechoice/feedback/p")
    xml_replace(p_node_temp, xml_find_first(htmlobj, "./body/ol/li/p[2]"))
    
    write_xml(output, file.path(tmpdir, glue("{name}_v{num}.xml")))
  }
  message("Step 2: Done")
  
  message("Step 3: Writing ZIP file")
  outfile <- file.path(outdir, glue("{name}.zip"))
  zip(outfile, file.path(tmpdir, glue("{name}_v{nn}.xml", nn = seq_len(n))))
  message("Step 3: Done. Output is", outfile)
  invisible(outfile)
}

