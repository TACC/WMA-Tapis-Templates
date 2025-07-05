# Kalpana

## What is Kalpana?

Kalpana is a Python script for post-processing of ADCIRC output files into GIS vector formats. The program was developed by the Coastal and Computational Hydraulics Team and North Carolina State University. For more details, check the [Kalpana repository](https://github.com/ccht-ncsu/Kalpana).

This project builds a containerized version of Kalpana software, built on top of the [mambaorg/micromamba](https://hub.docker.com/r/mambaorg/micromamba) base image. This image is then deployed as a [Tapis](https://tapis-project.org) application for use in the [DesignSafe](https://www.designsafe-ci.org) portal.

A second, separate application "kalpana-tacc" has also been developed for a [TACC fork of the project](https://github.com/TACC/Kalpana). The container was originally developed by Carlos del Castillo Negrete. Please note that the content and functionality of this script is dated and significantly different from the recent releases of Kalpana, because the project underwent a major overhaul by Tomas Cuevas in 2022.

See image documentation: [kalpana](kalpana/README.md), [kalpana-tacc](kalpana-tacc/README.md)

See Docker Hub pages: [ashtonvcole/kalpana](https://hub.docker.com/r/ashtonvcole/kalpana), [ashtonvcole/kalpana-tacc](https://hub.docker.com/r/ashtonvcole/kalpana-tacc)

## General Setup and Execution

There are two components to setup: the Docker image and the Tapis application. The Docker image provides a version-controlled environment to run the script consistently across computers. The Tapis application is a set of configurations to deploy the container on supercomputing resources via the DesignSafe portal. Tapis is an API which facilitates and manages jobs on supercomputers.

### Docker

#### Image

A Docker image may be pulled from [Docker Hub](https://hub.docker.com/r/ashtonvcole), or built locally with this command.

```bash
docker build -t [username]/[image name]:[tag] \
	--platform linux/amd64,linux/arm64 \
	-f [file name].Dockerfile \
	.
```

#### Container

See image documentation for the specifics of running each image: [kalpana](kalpana/README.md), [kalpana-TACC](kalpana-tacc/README.md)

To debug a container with an interactive shell:

```bash
docker run --rm -it --entrypoint=/bin/bash [image]
```

### Singularity/Apptainer

Docker images are generally compatible with Singularity, but it is important to be wary of some fundamental differences. Singularity containers use read-only file systems, so certain volume mounts are set up by default. The container also has access to the system's environment variables. Finally, certain commands in Dockerfiles like `WORKDIR` are ignored. However, these images should function under default settings.

```bash
singularity run docker://docker.io/[image] [options]
```

### Tapis Application

To submit JSON configurations for applications and jobs to a Tapis system, one either makes HTTP requests to the [web API](https://tapis-project.github.io/live-docs/) or its Python wrapper [tapipy](https://github.com/tapis-project/tapipy). See the [Tapis documentation](https://tapis.readthedocs.io/en/latest/getting-started/index.html) for a fuller description.

## Citation

Rucker, C.A., Tull, N., Dietrich, J.C., Langan, T.E., Mitasova, H., Blanton, B.O., Fleming, J.G. and Luettich, R.A., 2021. Downscaling of real-time coastal flooding predictions for decision support. Natural Hazards, 107, pp.1341-1369.