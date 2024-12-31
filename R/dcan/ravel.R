library(pbapply)
library(neurobase)

source("./normalizeRAVEL.R")

dir = "/users/9/reine097/data/fairview-ag/anonymized/4_processed/"
input.files  <- list.files(dir, full.names=TRUE)
brain.mask <- "/users/9/reine097/mni_icbm152_t1_tal_nlin_sym_09a_mask_int16.nii.gz" 
# Confirm the input arguments match the expected format and data types for the normalizeRAVEL function.
control.mask <- "/users/9/reine097/data/fairview-ag/anonymized/6_control_mask/control_mask_08.nii.gz"
normalizeRAVEL(input.files,
               brain.mask = brain.mask,
               control.mask = control.mask,
               k=1, 
               returnMatrix=TRUE,
               WhiteStripe=FALSE)
