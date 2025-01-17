library(neurobase)
source("utils.R")

dir   <- "/home/feczk001/shared/projects/S1067_Loes/data/Fairview-ag/03-csf_masked"
dir_rp <-"/home/feczk001/shared/projects/S1067_Loes/data/MIDB-rp/03-csf_masked"
masks <- list.files(dir, full.names=TRUE, pattern="*.nii.gz", recursive = TRUE)
masks_rp <- list.files(dir_rp, full.names=TRUE, pattern="*.nii.gz", recursive = TRUE)
all_masks <- c(masks, masks_rp)
intersect_mask  <- maskIntersect(all_masks, output.file="/home/feczk001/shared/projects/S1067_Loes/data/03-csf_masked/control_mask.nii.gz")
