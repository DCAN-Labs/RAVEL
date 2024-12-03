source("./R/utils.R")
dir   <- file.path(find.package("RAVELData"), "extdata")
masks <- list.files(dir, full.names=TRUE, pattern="*mask*.nii*")
intersect_mask  <- maskIntersect(masks, output.file=tempfile())
