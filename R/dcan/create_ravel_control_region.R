# TODO
# Make file paths command-line args.
# Troubleshooting Checklist:
#   Library Availability:
#   
#   Ensure the neurobase library is installed. If not, install it:
#   R
# Copy code
# install.packages("neurobase")
# Verify File Paths:
#   
#   Confirm that /users/9/reine097/csf_masks/ contains the intended NIfTI mask files.
# Ensure filenames match the *mask*.nii.gz pattern.
# utils.R File:
#   
#   Verify the existence and correctness of utils.R. Ensure it defines any required functions or setups for maskIntersect().
# Mask Intersection Output:
#   
#   Check if maskIntersect() executes successfully and writes the intersect_mask.nii.gz file to /users/9/reine097/csf_masks/.
# Expected Output:
#   A new file named intersect_mask.nii.gz in /users/9/reine097/csf_masks/, representing the intersection of all masks in the directory.
# Common Issues:
#   maskIntersect Not Found:
#   
#   If maskIntersect is not recognized, ensure the neurobase version supports it or check if it's defined in utils.R.
# Directory Permissions:
# 
# Confirm write permissions for /users/9/reine097/csf_masks/.
# File Pattern Mismatch:
# 
# Ensure the files in the directory match *mask*.nii.gz.

library(neurobase)

source("utils.R")

system("sg feczk001")

dir   <- file.path("/users/9/reine097/csf_masks/")
masks <- list.files(dir, full.names=TRUE, pattern="*mask*.nii.gz")
intersect_mask  <- maskIntersect(masks, output.file='/users/9/reine097/csf_masks/intersect_mask.nii.gz')
