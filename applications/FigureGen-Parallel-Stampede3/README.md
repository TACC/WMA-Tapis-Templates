## Overview
This is Figuregen Parallel app.

### Portals
It is used by DesignSafe Portal only and categorized under Visualization

### Usage

#### Inputs

Input Directory: tapis://designsafe.storage.community/app_examples/figuregen/input
Input File: FG51.inp


#### Expected Output

1. Look at tapis output files directory. Within InputDirectory, there should be a file `Ike0001.png`. View the file, if this image shows Ike's elevation info, then the app sanity test is good.

2. View tapisjob.out and you should see output similar to below. Look for `ibrun apptainer` and multiple cores being used. This is the difference between Parallel and serial versions of the app.

Note: gocryptfs INFO message seems to be just info and can be ignored.

```
++ ibrun apptainer run docker://clos21/figuregen-tacc-ubuntu18-impi19.0.7-common:latest figuregen -I FG51.inp
TACC:  Starting up job 6982521
TACC:  Starting parallel tasks...
INFO:    Using cached SIF image
...
INFO:    Using cached SIF image
INFO:    gocryptfs not found, will not be able to use gocryptfs
WARNING: release_mt library was used but no multi-ep feature was enabled. Please use release library instead.

--------------------------------------
FigureGen 51                2012/10/08

This program reads raw ADCIRC files
and uses GMT to generate a figure with
contours and vectors plotted within a
specified lat/lon box.
--------------------------------------

WARNING: Temporary folder doesn't exist.  FigureGen has created it.
Core 0000 read the input file.
Core 0001 read the input file.
Core 0022 read the input file.
Core 0003 read the input file.
Core 0004 read the input file.
Core 0007 read the input file.
Core 0011 read the input file.
...

Core 0000 processed the grid file.
Core 0000 created the contour palettes.

GENERATING IMAGES:

WARNING: There are more cores to use than time snaps to assign.  Some resources will be wasted.
Core 0001 started record 0001.
Core 0001 wrote the XYZ files for record 0001.
Core 0001 wrote the filled contours for record 0001.
Core 0001 wrote the scale for record 0001.
Core 0001 wrote the plot label for record 0001.
Core 0001 wrote the logo for record 0001.
Core 0001 created the raster images for record 0001.
Core 0001 completed record 0001.
Core 0000 received the all-clear from core 0001.
TACC:  Shutdown complete. Exiting.
++ cd ..
++ '[' '!' 0 ']'

```