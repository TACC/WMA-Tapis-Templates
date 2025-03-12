## Overview
This is Figuregen Serial app.

### Portals
It is used by DesignSafe Portal only and categorized under Visualization

### Usage

#### Inputs

Input Directory: tapis://designsafe.storage.community/app_examples/figuregen/input
Input File: FG51.inp


#### Expected Output

1. Look at tapis output files directory. Within InputDirectory, there should be a file `Ike0001.png`. View the file, if this image shows Ike's elevation info, then the app sanity test is good.

2. View tapisjob.out and you should see below output

Note: gocryptfs INFO message seems to be just info and can be ignored.

```
++ apptainer exec library://georgiastuart/figuregen/figuregen-serial figuregen -I FG51.inp
INFO:    Using cached image
INFO:    gocryptfs not found, will not be able to use gocryptfs

--------------------------------------
FigureGen 51                2012/10/08

This program reads raw ADCIRC files
and uses GMT to generate a figure with
contours and vectors plotted within a
specified lat/lon box.
--------------------------------------

WARNING: Temporary folder doesn't exist.  FigureGen has created it.
Core 0000 read the input file.

PRE-PROCESSING:

Core 0000 processed the grid file.
Core 0000 created the contour palettes.

GENERATING IMAGES:

Core 0000 started record 0001.
Core 0000 wrote the XYZ files for record 0001.
Core 0000 wrote the filled contours for record 0001.
Core 0000 wrote the scale for record 0001.
Core 0000 wrote the plot label for record 0001.
Core 0000 wrote the logo for record 0001.
Core 0000 created the raster images for record 0001.
Core 0000 completed record 0001.
++ cd ..
++ '[' '!' 0 ']'
```