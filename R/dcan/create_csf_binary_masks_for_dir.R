library(fslr)
library("oro.nifti")

source("create_csf_binary_mask.R")

scan_reg_n4_brain <- "/users/9/reine097/data/fairview-ag/anonymized/4_processed/sub-01_ses-01_space-MNI_brain_mprage.nii.gz"
output_file <- "/users/9/reine097/data/fairview-ag/anonymized/5_segmented/sub-01_ses-01_space-MNI_brain_mprage.nii.gz"
create_csf_binary_mask(scan_reg_n4_brain, output_file)
