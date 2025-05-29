# About
Napari is a fast, interactive, multi-dimensional image viewer for Python, designed for browsing, annotating, and analyzing large 2D, 3D, and higher-dimensional datasets

## App build details
uses Apptainer, `docker://taccaci/napari:0.4.17`
uses DCV, `taccaci/interactive-base:1.1.0`
runs on LS6

## Usage
In CEP, it is under 'Visualization'.
In 3DEM, it is under 'Interactive Analysis'.

## Inputs
1. Start the interactive app.
2. In the app, File --> Open Sample --> napari --> choose a file 

## Outputs

Once an image is loaded: 
1. Verify the buttons work: Points layer, Shapes layer, Labels layer, iPython console, nDisplay, transpose, Grid mode, Home

## Details on how this app is launched
1. CEP pulls the Napari Singularity image (`docker://taccaci/napari:0.4.17`) onto the LS6 node. 
2. Image is built FROM `taccaci/interactive-base:1.1.0,` which bundles all of the helper scripts, DCV setup, and common TACC modules.
3. Directory is bind-mounted into the container at startup.
4. An interactive SLURM job is created 
5. A pair of webhooks is registered at job launch: one for interactive connect events, another for job status updates.

## Note