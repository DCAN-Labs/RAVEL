source("normalize_intensity_with_ravel.R")

create_masks <- function(input_dir, output_dir) {
  # Author: Paul Reiners
  # Date: 2024-11-19
  
  files <- list.files(path=input_dir, pattern="*.nii.gz", full.names=TRUE, recursive=FALSE)
  lapply(files, function(scan_path) {
    base_name <- tools::file_path_sans_ext(basename(scan_path))
    cat("Base name:", base_name, "\n")
    if (!endsWith(base_name, 'Gd')) {
      normalize_intensity_with_ravel(scan_path, output_dir)
    }
  })
}
