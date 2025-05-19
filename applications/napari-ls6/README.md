# About
Napari is a fast, interactive, multi-dimensional image viewer for Python, designed for browsing, annotating, and analyzing large 2D, 3D, and higher-dimensional datasets

## App build details
uses Apptainer

## Usage
In CEP, it is under 'Visualization'.
In 3DEM, it is under 'Interactive Analysis'.

## Inputs
1. Start the interactive app.
2. In the app, File --> Open Sample --> chose a file 

## Outputs

Once an image is loaded: 
1. Verify the buttons work: Points layer, Shapes layer, Labels layer, iPython console, nDisplay, transpose, Grid mode, Home

## Details on how this app is launched
1. CEP pulls the pre-built Apptainer image for Napari onto the compute node. 
2. Directory is bind-mounted into the container at startup.
3. An interactive SLURM job is created 

## Note