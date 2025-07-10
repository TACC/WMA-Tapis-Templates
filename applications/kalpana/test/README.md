# Test Folder

This directory provides several scripts to test Kalpana on a Tapis system and locally.

## File Description

- [downscaling/](downscaling): Input files to test static downscaling functionality.
	- [fort.14](downscaling/fort.14): A mesh file of North Carolina.
	- [maxele.63.nc](downscaling/maxele.63.nc): Simulated maximum elevations from Hurricane Irene.
	- [NC_CoNED_subset_100m.tif](downscaling/NC_CoNED_subset_100m.tif): An elevation raster of the North Carolina coast.
	- [dzDaums_noaaTideGauges_msl_navd88.csv](downscaling/dzDaums_noaaTideGauges_msl_navd88.csv): Datums to convert between MSL and NAVD88.
- [`maxele.63.nc`](maxele.63.nc): A sample ADCIRC output file.
- [`maxvel.63.nc`](maxvel.63.nc): A sample ADCIRC output file.
- [`maxwvel.63.nc`](maxwvel.63.nc): A sample ADCIRC output file.
- ['scripts/'](scripts): Some use cases of Kalpana v0.0.24. For more help see [their own examples](https://github.com/ccht-ncsu/Kalpana/tree/master/examples).
	- [`hello_world.py`](scripts/hello_world.py): A script to submit to [ashtonvcole/kalpana](https://hub.docker.com/r/ashtonvcole/kalpana):v0.0.24, either locally or on a Tapis system.
	- [`nc2kmz_local.py`](scripts/nc2shp_local.py): A script converting an ADCIRC output to KMZ for Google Earth locally. WIP.
	- [`nc2shp_local.py`](scripts/nc2shp_local.py): A script converting an ADCIRC output to shapefile locally.
	- [`nc2shp_tapis.py`](scripts/nc2shp_tapis.py): A script converting an ADCIRC output to shapefile on a Tapis system.
	- [`static_downscaling_local.py`](scripts/static_downscaling_local.py): A script "downscaling" an ADCIRC output locally.
	- [`static_downscaling_tapis.py`](scripts/static_downscaling_tapis.py): A script "downscaling" an ADCIRC output on a Tapis system.
- [`test-tacc.sh`](test-tacc.sh): Test [ashtonvcole/kalpana-tacc](https://hub.docker.com/r/ashtonvcole/kalpana-tacc):1.0.0 locally.
- [`test-v0.0.24-interactive.sh`](test-v0.0.24-interactive.sh): Test [ashtonvcole/kalpana](https://hub.docker.com/r/ashtonvcole/kalpana):v0.0.24-jupyter-lab locally. This creates a Jupyter lab session to interact with the container, which you can access in your browser.
- [`test-v0.0.24-script.sh`](test-v0.0.24-script.sh): Test [ashtonvcole/kalpana](https://hub.docker.com/r/ashtonvcole/kalpana):v0.0.24 locally. The argument is one of the Python scripts in this directory, which gets mounted into the container and executed.