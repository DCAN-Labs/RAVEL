source("normalizeRAVEL.R")

system("sg feczk001")

input_files = list.files("/users/9/reine097/processed/", full.names = TRUE)
control_mask = "/home/feczk001/shared/projects/S1067_Loes/data/Fairview-ag/anonymized/intersect_mask.nii.gz"

normalizeRAVEL(input.files=input_files,
               brain.mask = "/home/feczk001/shared/projects/S1067_Loes/data/Fairview-ag/fMRIprep_anatonly_derivatives/nonGD/sub-01/ses-01/anat/sub-01_ses-01_run-01_space-MNI152NLin2009aSym_res-1_desc-brain_mask.nii.gz",
                           control.mask = control_mask,
               returnMatrix=FALSE,
                           WhiteStripe_Type = "T1",
                           writeToDisk = TRUE,
                           verbose = TRUE)
