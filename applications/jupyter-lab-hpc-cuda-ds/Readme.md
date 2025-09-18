### Overview
This iteration runs a jupyter-lab instance within a container with CUDA built in, based on the `nvidia/cuda:12.3.0-devel-ubuntu22.04` docker image. This is intended to be run on an HPC GPU node.

`$WORK`, `$HOME`, and `$SCRATCH` are symlinked into the base execution directory / home dir of the jupyter session, for easy access.

DesignSafe "MyData" is also mounted, for this designsafe-specific version.
