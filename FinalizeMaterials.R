### This program creates PDF slides and R files from the Rmd files

library(knitr)
library(here)

mypurl <- function(folder, fn){
   purl(here(folder, stringr::str_c(fn, ".Rmd")),
        output=here(folder, stringr::str_c(fn, ".R")),
        documentation=2)
   
}

mypurl("Exercises", "CategorialExercises")
mypurl("Exercises", "ContinuousExercises")
mypurl("Exercises", "WarmUpExercises")

mypurl("Exercises", "CategorialExercises_solutions")
mypurl("Exercises", "ContinuousExercises_solutions")
mypurl("Exercises", "WarmUpExercises_solutions")

mypurl("Presentation", "Slides")

# remotes::install_github("jhelvy/xaringanBuilder")
# remotes::install_github('rstudio/chromote')
xaringanBuilder::build_pdf(
   input=here("Presentation", "Slides.html"),
   output_file=here("Presentation", "Slides.pdf"),
   partial_slides= TRUE)
xaringanBuilder::build_pptx(
   input=here("Presentation", "Slides.pdf"),
   output_file=here("Presentation", "Slides.pptx"),
   partial_slides= TRUE)
