# About
Kalpana is a python script that converts ADCIRC output files to GIS compatible shapefiles. The code accepts NetCDF formatted ADCIRC outputs for maximum water levels and wind speeds (maxele.63.nc and maxwvel.63.nc) and converts these to polyline/polygon shapefiles.

## App build details
No container needed — this app is built natively on Frontera.

## Usage
In DesignSafe, it is under 'Visualization'. It runs on Frontera.

## Inputs
Kalpana has two main capabilities:
1. Create contours as polygons based on the maximum flooding (maxele.63.nc) or wind velocity (maxwvel.63.nc) outputs from ADCIRC, then export the polygons as a .shp file.
2. Create contours as polylines based on the maximum flooding (maxele.63.nc) or wind velocity (maxwvel.63.nc) outputs from ADCIRC, then export the polylines as a .shp file.

Testing Steps:
- For the Working Directory go to 'Community Data' and navigate to app_examples/adcirc_outputs (DesignSafe) or app_examples/kalpana (CEP) and select the maxwvel.63.nc file path as your working directory
- For the 'filetype' input type in maxwvel.63.nc
- For the 'polytype' input select polygon from the dropdown menu
- For the 'contour' input select contourlevel from the dropdown menu
- For the 'range' input type in: 0 1 2 3 4 5 6 7 8 9 10 11 12

- For developers, run the test job on the development queue for a maximum run time of 5 minutes

## Outputs

- Once the job is finished, there should be a directory called 'wind-speed' inside your archived output dir (i.e. the Output Location under Job History)

## Details on how this app is launched
1. Wrapper script from ZIP template starts DCV/VNC + runs visit
2. No container, no Docker, no MPI
3. Modules handle the VisIt environment (purge, TACC, intel, impi, visit)
4. Scheduler profile and job-name flags are critical for interactive desktop routing

## Note
