# Intro

Randomized multiple-select and single-select question generation for the
MyLearn teaching platform used by universities. Question templates in
the form of the [R/exams](http://www.r-exams.org/) package are
transformed into MyLearn’s XML format. Note that the feedback has to
stay simple, see the Issues section. The imported questions can be
organized into exams in the Learning Activities.

Dependencies:

  - `libxml2`: found on popular Linux distros and in Rtools by default
  - `pandoc`: gets installed by `R` during installation
  - `R`: a recent version
  - popular `R` packages: installed automatically

The question import functionality might have to be turned on by your
MyLearn support team.

# Installation

``` r
install.packages("devtools")
devtools::install_github("https://github.com/hdarjus/WU-MyLearn-QGen")
```

# Demo

One creates an `R/exams` compatible exercise file similar to
`example_question.Rmd`, decides for a name prefix and for the number of
generated exams.

``` r
library("exams.mylearn")
n <- 10L  # number of variants of the exercise
name <- "learn_exercise"  # prefix of the generated file names
exercise_file <- example_paths()["R_table"]
output <- exams2mylearn(filename = exercise_file,
                        n = n, dir = ".",
                        outfile = "question_table.zip")
```

The output .zip filepath is saved in `output`. One can upload that .zip
file to Learn directly (after the Learn development team has activated
that feature for the given course).

# Recommended Workflow

## Writing the Question Templates

The question templates are the .Rmd files. Find how-to’s in the files
returned by `example_paths()`. Best starting point is
`example_paths()["mixture"]`, that contains solutions to most features
you might need in an exam question.

The recommended way of debugging the questions is via

``` r
filename <- "potential-exercise.Rmd"
exams::exams2html(filename, n = 1L,
                  converter = "pandoc-mathjax",
                  verbose = TRUE)
```

The generated HTML file opened in the browser closely resembles the
looks of the exercise on MyLearn.

## Generating the Exercises

Set the current working directory to where the exercise templates are,
then run the following.

``` r
filenames <- list.files(pattern = ".*.Rmd$")
n <- 25L
for (filename in filenames) {
  exams2mylearn(filename, n = n,
                outfile = "exam-exercises.zip",
                dir = ".", dontask = TRUE)
}
```

### Tip

If you’re uploading improved exercises over and over again, I recommend
executing the following `for` loop instead:

``` r
filenames <- list.files(pattern = ".*.Rmd$")
n <- 500L
for (filename in filenames) {
  exams2mylearn(filename, n = n,
                outfile = "exam-exercises.zip",
                dir = ".", dontask = TRUE,
                distort.shortname = TRUE,
                verbose = TRUE)
}
```

This way the shortname will be unique every time and you will have more
feedback on where the generation process is.

### Special Characters on Windows

The .Rmd file is assumed to have UTF-8 encoding. That is important in
case the .Rmd file contains special (e.g. German) characters.

In RStudio, one can choose the encoding for file reading under *File* \>
*Reopen with Encoding*, and for file writing under *File* \> *Save with
Encoding*. It is recommended to do both with UTF-8.

## Uploading to MyLearn

In the course find *Administrate*, then under *“Old” learning materials*
click on *organize*. Then under *XML-file* choose the .zip file created
in the previous step. Finally, click on *Import learning materials*.

### First Upload

At the first upload a newly opened window shows a row for each exercise
in the .zip file. Those containing plots show a warning, that is normal.
By clicking on *Ansicht*, the uploaded exercise appears.

There is no way out from here, go back to the home page.

### Re-uploading with the Same Shortname

In this case a smaller list of the re-uploaded exercises is shown.
Choose all of them and click on *Submit*. This overwrites the old
versions.

## Importing Exercises

Yes, uploading and importing are different steps. In the menu of the
course’s *Learning activities*, click on *Import* \> *Import of existing
learning materials*. A table of uploaded exercises appears.

Use the filters to filter out your exercises. The most useful filters
are *Already imported* set to *No* and the text input where you can use
the unique shortnames.

Select all exercises with one click, then *Selected items* \> *Import*.
This brings you to the imported exercises. Select all and then *Selected
items* \> *Add to clipboard*.

## Organizing a Random Question on MyLearn

Create a new *Poolfolder* in the *Learning activities* and open it.
Click on *Clipboard* \> *Insert content here* and then *ok*. Release all
questions in the poolfolder otherwise the random question won’t work.

Now create a *Proxy* outside of the poolfolder and associate it with the
poolfolder you created. This was the last step, congratulations\!

The poolfolder contains the pool of questions that the random question
will choose from. It samples with replacement from the pool each time
someone opens the question. Poolfolders and their content are always
hidden from students.

At this point I recommend that you delete the exercises in the imported
view. For that: in the menu of the course’s *Learning activities*, click
on *Import* \> *Import of existing learning materials*. Delete all
exercises.

# Issues

1.  MyLearn handles only single select and multiple select questions.
2.  “Answerlist” in the Solution block doesn’t work on MyLearn.

# Maintainance

Should you find bugs or request features, please use the [Issue tracker
on Github](https://github.com/hdarjus/WU-MyLearn-QGen/issues).
