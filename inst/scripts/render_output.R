message("Moving into the vignettes directory")
setwd("vignettes")


message("Rendering output to markdown")
## Execute the code from the analysis
knitr::knit("output.Rmd.orig", output = "output.Rmd")


message("Rendering render to all other formats")
## Render to analysis to required output formats
rmarkdown::render("output.Rmd", 
                  output_dir = "rendered_output", 
                  knit_root_dir = c("."),
                  output_format = c("html_document"))

rmarkdown::render("output.Rmd", 
                  output_dir = "rendered_output", 
                  knit_root_dir = c("."),
                  output_format = c("md_document"))

message("Moving back into top level directory")
setwd("..")

message("Building all website docs")
## Make package website docs
pkgdown::build_site()