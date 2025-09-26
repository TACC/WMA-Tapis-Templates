### Overview
This iteration runs a jupyter-lab instance within a container, based on the `jupyter/datascience-notebook:ubuntu-22.04` docker image.

This version also compiles openmpi into the image.

`$WORK`, `$HOME`, and `$SCRATCH` are symlinked into the base execution directory / home dir of the jupyter session, for easy access.
