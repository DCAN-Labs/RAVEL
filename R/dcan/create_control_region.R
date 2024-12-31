library(neurobase)
source("utils.R")

dir   <- "/users/9/reine097/data/fairview-ag/anonymized/5_csf_masks/"
masks <- list.files(dir, full.names=TRUE, pattern="*.nii.gz")
intersect_mask  <- maskIntersect(masks, output.file="/users/9/reine097/data/fairview-ag/anonymized/control_mask_09.nii.gz", prob=0.9)
intersect_mask  <- maskIntersect(masks, output.file="/users/9/reine097/data/fairview-ag/anonymized/control_mask_08.nii.gz", prob=0.8)
