create_csf_binary_mask <- function(scan_reg_n4_brain, out_file) { 
  scan_reg_n4_brain_seg <- fast(scan_reg_n4_brain, verbose=FALSE, opts="-t 1 -n 3") 

  scan_reg_n4_brain_csf_mask <- scan_reg_n4_brain_seg
  scan_reg_n4_brain_csf_mask[scan_reg_n4_brain_csf_mask!=1] <- 0
  
  write_nifti(scan_reg_n4_brain_csf_mask, out_file)
}
