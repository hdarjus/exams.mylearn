# Create HTML files from the test examples


xexm <- exams2html(filename, name = glue("{name}_v"), n = n,
                   dir = tmpdir, converter = "pandoc-mathjax")