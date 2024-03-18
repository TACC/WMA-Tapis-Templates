# How to test the Kalpana v3 application

Kalpana has two main capabilities:
1) Create contours as polygons based on the maximum flooding (maxele.63.nc) or wind velocity (maxwvel.63.nc) outputs from ADCIRC, then export the polygons as a .shp file.
2) Create contours as polylines based on the maximum flooding (maxele.63.nc) or wind velocity (maxwvel.63.nc) outputs from ADCIRC, then export the polylines as a .shp file.

### Testing Steps
- For the Working Directory go to 'Community Data' and navigate to app_examples/kalpana and select the maxwvel.63.nc file path as your working directory
- For the 'filetype' input type in maxwvel.63.nc
- For the 'polytype' input select polygon from the dropdown menu
- For the 'contour' input select contourlevel from the dropdown menu
- For the 'range' input type in: 0 1 2 3 4 5 6 7 8 9 10 11 12

- For developers, run the test job on the development queue for a maximum run time of 5 minutes

- Once the job is finished, there should be a directory called 'windspeed' inside your archived output dir (i.e. the Output Location under Job History)