source("utils.R")

system("sg feczk001")

dir   <- file.path("/home/feczk001/shared/projects/S1067_Loes/data/Fairview-ag/anonymized/csf_masks/")
masks <- list.files(dir, full.names=TRUE, pattern="*mask*.nii.gz")
intersect_mask  <- maskIntersect(masks, output.file='intersect_mask.nii.gz')
