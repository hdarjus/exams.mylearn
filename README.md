Question Generation for MyLearn
===============================

The function `exams2mylearn` in `exams2mylearn.R` can generate
multiple-select questions with a simple feedback option in Learn's
import format. The imported questions can be organized into exams in the
Learning Activities.

Dependencies: \* libxml2 (it was on my Ubuntu by default) \* pandoc \*
recent R version

The question import functionality has to be turned on by the Learn
development team per course. Their address is "learn" at "wu" dot "ac"
dot "at".

Demo
----

One creates an `R/exams` compatible exercise file similar to
`example_question.Rmd`, decides for a name prefix and for the number of
generated exams.

    source("exams2mylearn.R")
    n <- 100L  # number of variants of the exercise
    name <- "learn_exercise"  # prefix of the generated file names
    exercise_file <- "example_question.Rmd"
    output <- exams2mylearn(filename = exercise_file,
                            name = name,
                            n = n)

The output zip file is `output`. One can upload that zip file to Learn
directly (after the Learn development team has activated that feature
for the given course).

Further Reading
---------------

For how to import the generated questions, please contact the learn
team.

For how you could use the imported questions, please read up on
Poolfolders and Proxy questions, Sample Exams, Strict Sequencing Study
Modules in the MyLearn-Guide.