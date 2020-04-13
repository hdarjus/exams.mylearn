Question Generation for MyLearn
===============================

Randomized multiple-select and single-select question generation for the
MyLearn platform at the Vienna University of Economics and Business.
Question templates in the form of the [R/exams](http://www.r-exams.org/)
package are transformed into MyLearn’s XML format. Note that the
feedback has to stay simple. The imported questions can be organized
into exams in the Learning Activities.

Dependencies:

-   libxml2 (it was on my Ubuntu by default)
-   pandoc
-   recent `R` version and popular `R` packages

The question import functionality has to be turned on by the Learn
development team per course. Their address is “learn” `at` “wu” `dot`
“ac” `dot` “at”.

Installation
------------

``` r
install.packages("devtools")
devtools::install_github("https://github.com/hdarjus/WU-MyLearn-QGen")
```

Demo
----

One creates an `R/exams` compatible exercise file similar to
`example_question.Rmd`, decides for a name prefix and for the number of
generated exams.

``` r
library("exams.wuvienna")
n <- 100L  # number of variants of the exercise
name <- "learn_exercise"  # prefix of the generated file names
exercise_file <- example_paths()["R_table"]
output <- exams2mylearn(filename = exercise_file,
                        name = name,
                        n = n)
```

The output zip filepath is saved in `output`. One can upload that zip
file to Learn directly (after the Learn development team has activated
that feature for the given course).

I have tested the framework with the examples returned by
`example_paths()`. I managed to upload 100 questions to Learn at the
same time and then import them in a Poolfolder, so it seems to work.

Further Reading
---------------

For how to import the generated questions, please contact the learn
team.

For how you could use the imported questions, please read up on
Poolfolders and Proxy questions, Sample Exams, Strict Sequencing Study
Modules in the MyLearn-Guide.

Maintainance
------------

Should you find bugs, please use the [Issue tracker on
Github](https://github.com/hdarjus/WU-MyLearn-QGen/issues). If you have
a minimal example of a .Rmd question that does not compile or Learn
gives an error at the stage of import, you can contact me under “darjus”
`dot` “hosszejni” `at` “wu” `dot` “ac” `dot` “at”. Please attach the
.Rmd file in question.
