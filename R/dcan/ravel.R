library(pbapply)
library(neurobase)
library(R.utils)
library(RAVEL)
library(oro.nifti)

dir = "/home/feczk001/shared/projects/S1067_Loes/data/Fairview-ag/02-preproc_anonymized/"
input.files  <- list.files(dir, full.names=TRUE, recursive = FALSE, pattern = "*.nii.gz")
brain.mask <- "/home/feczk001/shared/projects/S1067_Loes/data/MNI152/mni_icbm152_nlin_sym_09a/mni_icbm152_t1_tal_nlin_sym_09a_mask_int16.nii.gz" 
# Confirm the input arguments match the expected format and data types for the normalizeRAVEL function.
control.mask <- "/home/feczk001/shared/projects/S1067_Loes/data/Fairview-ag/control_mask.nii.gz"
check_nifti(brain.mask)
check_nifti(control.mask)

oro.nifti::readNIfTI(input.files[1], reorient = FALSE)
oro.nifti::readNIfTI(brain.mask, reorient = FALSE)
oro.nifti::readNIfTI(control.mask, reorient = FALSE)

tryCatch({
  normalizeRAVEL(input.files, brain.mask = brain.mask, control.mask = control.mask, k = 1, writeToDisk = TRUE, WhiteStripe = FALSE, verbose=FALSE)
}, error = function(e) {
  message("Error: ", e)
  message("Missing files:")
  message("Input files: ", paste(input.files[!file.exists(input.files)], collapse = ", "))
  message("Brain mask: ", ifelse(file.exists(brain.mask), "Found", "Missing"))
  message("Control mask: ", ifelse(file.exists(control.mask), "Found", "Missing"))
})
