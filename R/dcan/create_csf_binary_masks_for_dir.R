library(fslr)
library("oro.nifti")

source("R/dcan/create_csf_binary_mask.R")
source("./R/utils.R")

in_dir <- "/home/feczk001/shared/projects/S1067_Loes/data/Fairview-ag/02-preproc_anonymized/"
non_gd_pattern = "^((?!.*Gd.*).)*$"
in_files <- list.files(path = in_dir, pattern = "^((?!.*Gd.*).)*$",
                       full.names = TRUE)
out_dir <- "/users/9/reine097/data/fairview-ag/anonymized/5_csf_masks/"
ifelse(!dir.exists(out_dir), dir.create(out_dir), "Folder exists already")
for (scan_reg_n4_brain in in_files) {
  out_base_name <- basename(scan_reg_n4_brain)
  output_file <- file.path(out_dir, out_base_name)
  create_csf_binary_mask(scan_reg_n4_brain, output_file)
}
