source("./R/utils.R")
dir   <- file.path("/users/9/reine097/data/fairview-ag/anonymized/skull_stripped_anonymized_sample/")
masks <- list.files(dir, full.names=TRUE, pattern="*mask*.nii*")
intersect_mask  <- maskIntersect(masks, output.file=tempfile())
