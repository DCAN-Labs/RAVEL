# RAVEL
### Imaging suite for the preprocessing and statistical analysis of MRIs in R.
--------
**Creator**: Jean-Philippe Fortin, jeanphi@mail.med.upenn.edu

**Authors**: Jean-Philippe Fortin, John Muschelli, Russell T. Shinohara

##### Software status

| Resource:      | Travis CI     |
| -------------  |  ------------- |
| Platform:      | OSX       |
| R CMD check    | <a href="https://travis-ci.org/Jfortin1/RAVEL"><img src="https://travis-ci.org/Jfortin1/RAVEL.svg?branch=master" alt="Build status"></a> |

##### References

| Method      | Citation     | Paper Link
| -------------  | -------------  | -------------  |
| RAVEL    |  Jean-Philippe Fortin, Elizabeth M Sweeney, John Muschelli, Ciprian M Crainiceanu, Russell T Shinohara, Alzheimer's Disease Neuroimaging Initiative, et al. **Removing inter-subject technical variability in magnetic resonance imaging studies**. NeuroImage, 132:198–212, 2016.      | [Link](http://www.sciencedirect.com/science/article/pii/S1053811916001452) |
| WhiteStripe    | Russell T Shinohara, Elizabeth M Sweeney, Jeff Goldsmith, Navid Shiee, Farrah J Mateen, Peter A Calabresi, Samson Jarso, Dzung L Pham, Daniel S Reich, Ciprian M Crainiceanu, Australian Imaging Biomarkers Lifestyle Flagship Study of Ageing, and Alzheimer’s Disease Neuroimaging Initiative. **Statistical normalization techniques for magnetic resonance  imaging**. Neuroimage Clin, 6:9–19, 2014.    |[Link](http://www.sciencedirect.com/science/article/pii/S221315821400117X)| 



## Table of content
- [1. Introduction](#id-section1)
- [2. Image preprocessing](#id-section2)
- [3. Intensity normalization and RAVEL correction](#id-section3)
- [4. Statistical analysis](#id-section4)



<div id='id-section1'/>
## 1. Introduction

RAVEL is an R package that combines the preprocessing and statistical analysis of magnetic resonance imaging (MRI) datasets within one framework. Users can start with raw images in the NIfTI format, and end up with a variety of statistical results associated with voxels and regions of interest (ROI) in the brain. RAVEL stands for _Removal of Artificial Voxel Effect by Linear regression_, the main preprocessing function of the package that allows an effective removal of between-scan unwanted variation. We have shown in [a recent paper](http://www.sciencedirect.com/science/article/pii/S1053811916001452) that RAVEL improves significantly population-wide statistical inference. The vignette is divided into several sections. In Section 1, we present a pre-normalization preprocessing pipeline from raw images to processed images ready for intensity normalization. In Section 2, we explain how to use the RAVEL algorithm as well as other intensity normalization techniques. In Section 3, we present different tools for post-normalization statistical analysis. In Section 4, we present additional functions that help the visualization of images and statistical results. 

##### Installation

```{r}
library(devtools)
install_github("jfortin1/RAVEL")
```




<div id='id-section2'/>
## 2. Image preprocessing 



We present a pre-normalization preprocessing pipeline implemented in the R software, from raw images to images ready for intensity normalization and statistical analysis. Once the images are preprocessed, users can apply their favorite intensity normalization and the scan-effect correction tool RAVEL as presented in Section 1 above. We present a preprocessing pipeline that uses the R packages `ANTsR` and `fslr`. While we have chosen to use a specific template space (JHU-MNI-ss), a specific registration (non-linear diffeomorphic registration) and a specific tissue segmentation (FSL FAST), users can choose other algorithms prior to intensity normalization and in order for RAVEL to work. The only requirement is that the images are registered to the same template space. 

#### 2.1. Prelude

To preprocess the images, we use the packages `fslr` and `ANTsR`. The package `fslr` is available on CRAN, and requires FSL to be installed on your machine; see the [FSL website](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/) for installation. For `ANTsR`, we recommend to install the latest stable version available at the ANTsR [GitHub page](https://github.com/stnava/ANTsR/releases/). The version used for this vignette was `ANTsR_0.3.2.tgz`. For the template space, we use the JHU-MNI-ss atlas (see Section 1.2) included in the `EveTemplate` package, available on GitHub at [https://github.com/Jfortin1/EveTemplate](https://github.com/Jfortin1/EveTemplate). 
For data examples, we use 4 T1-w scans from the package `RAVELData` available on GitHub at [https://github.com/Jfortin1/RAVELData](https://github.com/Jfortin1/RAVELData). 
Once the packages are properly installed, we are ready to start our preprocessing of T1-w images. We first load the packages into R:

```{r}
library(fslr)
library(ANTsR)
library(RAVELData)
library(EveTemplate)
have.fsl() # Should be TRUE if fsl is correctly installed
```

and let's specify the path for the different files that we will need:
```{r}
# JHU-MNI-ss template:
template_path <- getEveTemplatePath("T1")
# JHU-MNI-ss template brain mask:
template_brain_mask_path <- getEveTemplatePath("Brain_Mask")
# Example of T1-w MPRAGE image
scan_path <- system.file(package="RAVELData", "data/scan1.nii.gz")
```

#### 2.2. JHU-MNI-ss template (_EVE_ atlas)



#### 2.3. Registration to template

Tp perform a non-linear registration to the JHU-MNI-ss template, one can use the diffeomorphism algorithm via the `ANTsR` package.  Note that we perform the registration with the skulls on. Here is an example where we register the scan1 from the `RAVELData` package to the JHU-MNI-ss template:

```{r}
template    <- antsImageRead(template_path, 3)
scan <- antsImageRead(scan_path,3)
outprefix <- gsub(".nii.gz","",scan_path) # Prefix for the output files
output <- antsRegistration(fixed = template, moving = scan, typeofTransform = "SyN",  outprefix = outprefix)
scan_reg   <- antsImageClone(output$warpedmovout) # Registered brain
```
The object `scan_reg` contains the scan registed to the template. Note that the object is in the `ANTsR` format. Since I prefer to work with the `oro.nifti` package, which is compatible with `flsr`, I convert the object to a `nifti` object using the function `ants2oro` as follows:

```{r}
scan_reg <- ants2oro(scan_reg)
```
I can save the registered brain in the NIfTi format using the `writeNIfTI` command:

```{r}
writeNIfTI(scan_reg, "scan_reg")
```
Since `scan_reg` is converted to a `nifti` object, we can use the function `ortho2` from the `fslr` package to visualize the scan: 

```{r}
ortho2(scan_reg, crosshairs=FALSE, mfrow=c(1,3), add.orient=FALSE)
```

#### 2.4. Intensity inhomogeneity correction

We perform intensity inhomogeneity correction on the registered scan using the N4 Correction from the `ANTsR` package:

```{r}
scan_reg <- oro2ants(scan_reg) # Convert to ANTsR object
scan_reg_n4 <- n4BiasFieldCorrection(scan_reg)
scan_reg_n4 <- ants2oro(scan_reg_n4) # Conversion to nifti object for further processing
```

#### 2.5. Skull stripping

```{r}
template_brain_mask <- readNIfTI(template_brain_mask_path, reorient=FALSE)
scan_reg_n4_brain <- niftiarr(scan_reg_n4, scan_reg_n4*template_brain_mask)
```

Visualization:

```{}
ortho2(scan_reg_n4_brain, crosshairs=FALSE, mfrow=c(1,3), add.orient=FALSE)
```
 
#### 2.6. Tissue Segmentation

There are different tissue segmentation algorithms available in R. My favorite is the FSL FAST segmentation via the [`fslr`](https://cran.r-project.org/web/packages/fslr/index.html) package. 

Let's produce the tissue segmentation for the `scan_reg_n4_brain` scan above:

```{r}
ortho2(scan_reg_n4_brain, crosshairs=FALSE, mfrow=c(1,3), add.orient=FALSE, ylim=c(0,400))
```
The last line of code produces via the `ortho2` function from the `fslr` package the following visualization of the template:


<p align="center">
<img src="https://github.com/Jfortin1/RAVEL/blob/master/images/template.png" width="600"/>
</p>

We perform a 3-class tissue segmentation on the T1-w image with the FAST segmentation algorithm:

```{r}
scan_reg_n4_brain_seg <- fast(scan_reg_n4_brain, verbose=FALSE, opts="-t 1 -n 3") 
ortho2(scan_reg_n4_brain_seg, crosshairs=FALSE, mfrow=c(1,3), add.orient=FALSE)
```
<p align="center">
<img src="https://github.com/Jfortin1/RAVEL/blob/master/images/seg.png" width="600"/>
</p>


The object `scan_reg_n4_brain_seg` is an image that contains the segmentation labels `0,1,2` and `3` referring to Background, CSF, GM and WM voxels respectively. 

  
#### 2.7. Creation of a tissue mask

Suppose we want to create a mask for CSF.

```{r}
scan_reg_n4_brain_csf_mask <- scan_reg_n4_brain_seg
scan_reg_n4_brain_csf_mask[scan_reg_n4_brain_csf_mask!=1] <- 0
ortho2(scan_reg_n4_brain_csf_mask, crosshairs=FALSE, mfrow=c(1,3), add.orient=FALSE)
```
We use the fact that the file `scan_reg_n4_brain_seg` is equal to 1 for CSF, 2 for GM and 3 for WM. FOr instance, a WM mask could be created as follows:

```{r}
scan_reg_n4_brain_wm_mask <- scan_reg_n4_brain_seg
scan_reg_n4_brain_wm_mask[scan_reg_n4_brain_wm_mask!=3] <- 0
ortho2(scan_reg_n4_brain_wm_mask, crosshairs=FALSE, mfrow=c(1,3), add.orient=FALSE)
```

<div id='id-section3'/>
## 3. Intensity normalization and RAVEL correction

Since MRI intensities are acquired in arbitrary units, image intensities are not comparable across scans, between subjects and across sites. Intensity normalization (or intensity standardization) is paramount before performing between-subject intensity comparisons. The `RAVEL` package includes the popular histogram matching normalization (`normalizeHM`) as well as the White Stripe normalization (`normalizeWS`); see the table below for the reference papers. Once the images intensities are normalized, the RAVEL correction tool can be applied using the function `normalizeRAVEL` to remove additional unwanted variation using a control region. Because we have found that the combination White Stripe + RAVEL was best at removing unwanted variation, the function `normalizeRAVEL` performs White Stripe normalization by default prior to the RAVEL correction. 

Note: registration is also called _spatial normalization_ which is unrelated to _intensity normalization_. 

##### Available methods

| Function     | Method  | Modalities supported at the moment| Paper Link
| -------------  | -------------  | -------------  | ----------- |
| `normalizeRaw` | No normalization | T1, T2, FLAIR, PD | |
| `normalizeRAVEL` | RAVEL   |T1, T2, FLAIR| [Link](http://www.sciencedirect.com/science/article/pii/S1053811916001452) |
| `normalizeWS`    | White Stripe |T1, T2, FLAIR |[Link](http://www.sciencedirect.com/science/article/pii/S221315821400117X)| 
| `normalizeHM` |Histogram Matching   |T1, T2 | [Link](http://www.ncbi.nlm.nih.gov/pubmed/10571928)| 

Briefly, each function takes as input a list of NIfTI file paths specifying the images to be normalized, and return a matrix of normalized intensities where rows are voxels and columns are scans. We note that the input files must be the files associated with  preprocessed images registered to a common template. The different functions are described below. 

### 3.1 No normalization

The function `normalizeRaw` takes as input the preprocessed and registered images, and create a matrix of voxel intensities without intensity normalization. For conventional MRI images, we recommend to apply an intensity normalization to the images (see `normalizeWS` or `normalizeRAVEL`). The main purpose of the function `normalizeRaw` is for exploration data analysis (EDA), methods development and methods comparison. 

| Argument     | Description  | Default
| -------------  | -------------  | -------------  | 
| `input.files` | `vector` or `list` of the paths for the input NIfTI image files to be normalized 
| `output.files` | Optionnal `vector` or `list` of the paths for the output images. By default, will be the `input.files` with "_RAW" appended at the end.   | `NULL`
| `brain.mask`  | NIfTI image path for the binary brain mask. Must have value `1` for the brain and `0` otherwise 
| `returnMatrix` | Should the matrix of normalized images be returned? Rows correspond to voxels specified by `brain.mask`, and columns correspond to scans. | `TRUE`
| `writeToDisk` | Should the normalized images be saved to the disk as NIfTI files? |`FALSE`
| `verbose` | Should the function be verbose? | `TRUE` 


### 3.2 White Stripe normalization

The function `normalizeWS` takes as input the preprocessed and registered images, applies the White Stripe normalization algorith to each image separately via the `WhiteStripe` R package, and creates a matrix of normalized voxel intensities. Note that the White Stripe normalization is also included as a first step in the RAVEL algorithm implemented in the `normalizeRAVEL` function. 

| Argument     | Description  | Default
| -------------  | -------------  | -------------  | 
| `input.files` | `vector` or `list` of the paths for the input NIfTI image files to be normalized 
| `output.files` | Optionnal `vector` or `list` of the paths for the output images. By default, will be the `input.files` with "_WS" appended at the end.   | `NULL`
| `brain.mask`  | NIfTI image path for the binary brain mask. Must have value `1` for the brain and `0` otherwise 
| `WhiteStripe_Type` | What is the type of images to be normalized? Must be one of "T1", "T2" and "FLAIR". | `T1`
| `returnMatrix` | Should the matrix of normalized images be returned? Rows correspond to voxels specified by `brain.mask`, and columns correspond to scans. | `TRUE`
| `writeToDisk` | Should the normalized images be saved to the disk as NIfTI files? |`FALSE`
| `verbose` | Should the function be verbose? | `TRUE` 

### 3.3 Histogram matching normalization

Not ready yet. 

### 3.4 RAVEL normalization

The function `normalizeRAVEL` takes as input the preprocessed and registered images, and a control region mask, and applies the RAVEL correction method to create a matrix of normalized voxel intensities. The White Stripe normalization is included by default as a first step in the RAVEL algorithm. The next section explains how to create a control region mask.

| Argument     | Description  | Default
| -------------  | -------------  | -------------  | 
| `input.files` | `vector` or `list` of the paths for the input NIfTI image files to be normalized 
| `output.files` | Optionnal `vector` or `list` of the paths for the output images. By default, will be the `input.files` with "_RAVEL" appended at the end.   | `NULL`
| `brain.mask`  | NIfTI image path for the binary brain mask. Must have value `1` for the brain and `0` otherwise 
| `control.mask` | NIfTI image path for the binary control region mask. Must have value `1` for the control region and `0` otherwise. See the helper function `mask_intersect` for the creation of a `control.mask`.  
| `WhiteStripe` | Should White Stripe normalization be performed before RAVEL? | `TRUE` 
| `WhiteStripe_Type` | If `WhiteStripe` is `TRUE`, what is the type of images to be normalized? Must be one of "T1", "T2" and "FLAIR". | `T1`
| `k` | Integer specifying the number of principal components to be included in the RAVEL correction. | `1`
| `returnMatrix` | Should the matrix of normalized images be returned? Rows correspond to voxels specified by `brain.mask`, and columns correspond to scans. | `TRUE`
| `writeToDisk` | Should the normalized images be saved to the disk as NIfTI files? |`FALSE`
| `verbose` | Should the function be verbose? | `TRUE` 

### 3.1.1 Creation of a control region for RAVEL

RAVEL uses a control region of the brain to infer unwanted variation across subjects. The control region is made of voxels that are known to be not associated with the phenotype of interest. For instance, it is known that the CSF intensities on T1-w images are not associated with the progression of AD. The control region must be specified in the argument `control.mask` of the function `normalizeRAVEL` as a path to a NIfTI file storing the binary mask. In the case of a CSF control region, one way to create such a binary mask is to create a CSF binary mask for each image, and then take the intersection of all binary masks to create a common CSF binary mask for all images. The helper function `mask_intersect` will take as input a list of binary masks (either `nifti` objects or a list of NIfTI file paths), and will output the intersection of all binary masks. By default, the function will save the intersection mask to the disk as a NIfTI file, as specified by `output.file` 

Example:

```{r}
mask <- mask_intersect(list("csf_mask1.nii.gz", "csf_mask2.nii.gz", "csf_mask3.nii.gz"),
    output.file="intersection_mask.nii.gz")
```

<div id='id-section4'/>
## 4. Statistical analysis


##### Creation of T-maps

##### Mean-variance relationship

##### Empirical Bayes

### 4. Analysis of RAVENS maps

### 5. Advanced visualization

### 6. Miscellaneous

##### Coregistration (for more than one modality)

##### RAVEL for longitudinal data

##### RAVEL for multimodal data




