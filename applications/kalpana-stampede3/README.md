# About

Kalpana is a Python script for post-processing of ADCIRC output files into GIS vector formats. The program was developed by the Coastal and Computational Hydraulics Team and North Carolina State University. For more details, check the [Kalpana repository](https://github.com/ccht-ncsu/Kalpana).

Kalpana has two main capabilities:
1) Create contours as polygons based on the maximum flooding (maxele.63.nc) or wind velocity (maxwvel.63.nc) outputs from ADCIRC, then export the polygons as a .shp file.
2) Create contours as polylines based on the maximum flooding (maxele.63.nc) or wind velocity (maxwvel.63.nc) outputs from ADCIRC, then export the polylines as a .shp file.

## App build details
Uses Apptainer: docker://docker.io/taccaci/kalpana-nc2shp:v0.0.24
Based on: taccaci/kalpana-stampede3:v0.0.24
Runs on: Stampede3

## Usage
In DesignSafe, it is under 'Visualization'. It runs on Stampede3.

## Inputs
Testing Steps:
- For the ADCIRC File type go to 'Community Data' and navigate to [Community Data/app_examples/adcirc_outputs/maxele.63.nc](tapis://designsafe.storage.community/app_examples/adcirc_outputs/maxele.63.nc)
- For the Contour Levels parameter type in: --levels 0 50 0.1
- For the 'Contour Type' parameter select: polygon
- For the 'Vertical Units Out' parameter select: ft
- For the 'Vertical Units In' parameter select: ft

## Outputs

- Once the job is finished, the results should be in the 'inputDirectory' directory inside your archived output dir (i.e. the Output Location under Job History)

 Note: For an output example navigate to 
 [Community Data/app_examples/adcirc_outputs/testCase1](https://www.designsafe-ci.org/data/browser/tapis/designsafe.storage.community/%2Fapp_examples%2Fadcirc_outputs%2FtestCase1)

 ## Details on how this app is launched

1. DESIGN SAFE pulls the Kalpana kalpana-nc2shp image (docker://docker.io/taccaci/kalpana-nc2shp:v0.0.24) designed to run the nc2shp function onto the Stampede3 node.
2. Image is built FROM taccaci/kalpana:v0.0.24. This image is built on top of mambaorg/micromamba:2.3. It sets up all necessary dependencies in the base environment and imports its code from official releases of Kalpana.
3. The user's working directory is bind-mounted into the container.