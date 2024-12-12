source("create_masks.R")

# input_dir <- '/users/9/reine097/data/fairview-ag/anonymized/processed/'
# output_dir <- '/users/9/reine097/data/fairview-ag/anonymized/raveled/'

# Check current working directory and see if the path is very long!
cat("working dir: ", getwd(), "\n")
# set the current script's location as working directory
# setwd(dirname(rstudioapi::getSourceEditorContext()$path))

args <- commandArgs(trailingOnly = TRUE)
# Check if arguments are provided
if (length(args) == 0) {
  stop("No arguments provided")
}
# Print the arguments
print(args)
# Example: Access individual arguments
input_dir <- args[1]
output_dir <- args[2]

# Print individual arguments
cat("input_dir: ", input_dir, "\n")
cat("output_dir:", output_dir, "\n")

create_masks(input_dir, output_dir)
