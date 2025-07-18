# About
Fiji ("Fiji Is Just ImageJ") is an open-source platform for biological-image analysis. It is built on ImageJ and includes a curated collection of plugins for advanced image processing, 3D visualization, and analysis workflows, especially suited for microscopy data.

## App build details
Uses Apptainer: docker://taccaci/fiji:20240116
Based on: taccaci/interactive-base:1.1.0
Runs on: LS6

## Usage
In CEP, it's under 'Visualization'
In 3DEM, it's under 'Interactive Analysis'
In UTRC, it's under 'Data Processing'

## Inputs
1. Start the interactive app.
2. In Fiji, go to File → Open... to select and load your image files (TIFF, JPEG, LSM, etc.).
   Sample Imports at the bottom of the list work for testing.

## Outputs
Once an image is loaded:
    1. Verify that common operations work: brightness/contrast, measurements, ROI tools, and 3D Viewer.
    2. Try running a macro or plugin to confirm full functionality.
    3. Python scripting (via Jython) can be accessed under Plugins → Scripting.

## Details on how this app is launched
1. CEP pulls the Fiji Apptainer image (docker://taccaci/fiji:20240116) onto the LS6 node.
2. Image is built FROM taccaci/interactive-base:1.1.0, which provides DCV, helper scripts, and default modules.
3. The user’s working directory is bind-mounted into the container.
4. An interactive SLURM job is created at launch.
5. Webhooks are used for managing job status and interactive session connections.


## Note
