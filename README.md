# Automated-Analysis-of-FAs-and-Cell-Morphology_Deng
Open source repository for source code for "Consolidation of Cell-ECM Adhesion Through Direct Talin-mediated Actin Linkage is Essential for Mouse Embryonic Morphogenesis" (Wenjun Deng, Rosalynn L. Carr, Rhea R. Kaul, Marina Pavlova, Amanada Haage, Pere Roca-Cusachs, Guy Tanentzapf).

## System Requirements
- See System Requirements for MATLAB.
-	See Introduction to R
-	This script has been tested on MATLAB R2023a

## Installation
- See Download MATLAB to download MATLAB. MATLAB files can be downloaded from this repository.
- See Download R to download R. R files can be downloaded from this repository.

## Instructions for Use – Focal Adhesion and Cell Morphology analysis (MATLAB)
- Ensure you have downloaded all MATLAB files from this repository. The folders include sub folders for only actin analysis, only focal adhesion analysis, and analysis of both actin and focal adhesions.
- Z-stacks for images must be stored in sub-folders ending in ‘frames’.
- Image z-stacks for analysis must be in '.tif' format and stored within the same folder.
- Please note that there is an option to adjust filter sizes in each MATLAB function depending on the resolution of your images. Adjusting filter size is important to ensure accurate results are produced for images. Unadjusted filter sizes may lead to harsh filtering. Some changes in resolution have been accounted for but it is recommended to check before use.

### runQuantifications (Compiled script – Cell Morphology and FA both)
- This files needed for both focal adhesion and actin analysis are 'runQuantifications.m', 'FAData.m', 'cellData.m', ‘actinData.m’, ‘protrusionData.m’, ‘allOtherCellTypesFilter.m’, ‘TalinHomozygousFilter.m’, ‘FARawData.xlsx’, ‘ProtrusionRawData.xlsx’ and 'Results.xlsx'.
- This is for images that have focal adhesion channels as well as an actin channel. The code may generate an error if the images do not have focal adhesion or actin channels.
- Open MATLAB, ensure all files are in the workspace, and run 'runQuantifications.m'.
- Select folder containing the z-stack subfolders. The code is designed for batch processing and will analyse all the images in each subfolder. Please make sure they are the same in terms of stain type.
- Select the channels for actin, focal adhesion stain 1, and focal adhesion stain 2. Please selected ‘None’ for actin if no actin channel is present.
- Select the filter type based on the cell you are analysing. For cells with bright noise around the nucleus, select the talinHomozygous filter. For all other cells, select allOtherCellTypes filter.
- Declare the conversion factor, that is, the scale of your image in µm/pixel.
- The script will output 3 ‘.xlsx’ files: protrusion raw data, focal adhesion raw data, and the results. 
- If you would like to see and save a montage of your original image and the mask image, please uncomment the section labelled “Option to save masked image” in the ‘FAData.m’ file.

### runQuantifications (FA only script)
- The files needed for only focal adhesion analysis are 'runQuantifications.m', 'FAData.m', ‘allOtherCellTypesFilter.m’, ‘TalinHomozygousFilter.m’, ‘FARawData.xlsx’ and 'Results.xlsx'.
- This is for images that only have focal adhesion channels. The code may generate an error if the images do not have focal adhesion channels.
- Open MATLAB, ensure all files are in the workspace, and run 'runQuantifications.m'.
- Select folder containing the z-stack subfolders. The code is designed for batch processing and will analyse all the images in each subfolder. Please make sure they are the same in terms of stain type.
- Select the channels for focal adhesion stain 1 and focal adhesion stain 2.
- Select the filter type based on the cell you are analysing. For cells with bright noise around the nucleus, select the talinHomozygous filter. For all other cells, select allOtherCellTypes filter.
- Declare the conversion factor, that is, the scale of your image in µm/pixel.
- The script will output 2 ‘.xlsx’ files: focal adhesion raw data and the results. 
- If you would like to see and save a montage of your original image and the mask image, please uncomment the section labelled “Option to save masked image” in the ‘FAData.m’ file.

### runQuantifications (Cell Morphology only script)
- The files needed for only cell morphology analysis 'runQuantifications.m', 'cellData.m', ‘actinData.m’, ‘protrusionData.m’, ‘ProtrusionRawData.xlsx’ and 'Results.xlsx'.
- This is for images that only have actin channels. The code may generate an error if the images do not have actin channels.
- Open MATLAB, ensure all files are in the workspace, and run 'runQuantifications.m'.
- Select folder containing the z-stack subfolders. The code is designed for batch processing and will analyse all the images in each subfolder. Please make sure they are the same in terms of stain type.
- Select the channels for actin.
- Declare the conversion factor, that is, the scale of your image in µm/pixel.
- The script will generate a graph for protrusion data and an image with actin fibre alignment for each image as it runs.
- The script will output 2 ‘.xlsx’ files: protrusion raw data and the results. 
