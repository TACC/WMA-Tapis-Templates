# About
The OpenFOAM (Open Field Operation and Manipulation) CFD (Computational Fluid Dynamics) Toolbox is a free, open source CFD software package which has a large user base across most areas of engineering and science, from both commercial and academic organizations.

## App build details
No container needed — this app is built natively on Stampede3.

## Usage
In DesignSafe, it is under 'Simulation'. It runs on Stampede3.

## Inputs
Testing Steps:
- For the Case Directory go to 'Community Data' and navigate to [Community Data/app_examples/openfoam/openfoam_v12/testCase1](https://www.designsafe-ci.org/data/browser/tapis/designsafe.storage.community/%2Fapp_examples%2Fopenfoam%2Fopenfoam_v12%2FtestCase1)
- For the 'Decomposition' parameter select Off
- For the 'Mesh' parameter select On
- For the 'Mesh' parameter select On

- For developers, run the test job on the skx-dev queue for a maximum run time of 60 minutes

## Outputs

- Once the job is finished, the results should be in the 'inputDirectory' directory inside your archived output dir (i.e. the Output Location under Job History)

## Details on how this app is launched
1. Wrapper script from ZIP template runs openfoam module
2. No container, no Docker, no MPI

## Note
