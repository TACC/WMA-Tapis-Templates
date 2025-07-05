# TACC-Forked Kalpana Image

## What is Kalpana?

Kalpana is a Python script for post-processing of ADCIRC output files into GIS vector formats. The program was developed by the Coastal and Computational Hydraulics Team and North Carolina State University. For more details, check the [Kalpana repository](https://github.com/ccht-ncsu/Kalpana).

See Docker Hub page: [ashtonvcole/kalpana-tacc](https://hub.docker.com/r/ashtonvcole/kalpana-tacc)

## Image Description

This image is built on top of [mambaorg/micromamba](https://hub.docker.com/r/mambaorg/micromamba):2.3. It sets up all necessary dependencies in the base environment and imports its code from the [TACC fork of Kalpana](https://github.com/TACC/Kalpana) into `/app`. Please note that the content and functionality of this script is dated and significantly different from the recent releases of Kalpana, because the project underwent a major overhaul by Tomas Cuevas in 2022.

The entrypoint of the image runs the script, `ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "python" , "/app/Kalpana/Kalpana_N.py"]`. The default flag appended is help instructions, `CMD ["--help"]`. Thus, to override the help flag, one simply appends the necessary flags to the end of the docker run command. The default working directory is `/home/mambauser`.

## Usage

This version of Kalpana executes as a serial script. The user should make ADCIRC files accessible to the container via a volume mount, and then direct the Kalpana outputs to the same or another mount.

By default, the container runs from the working directory `/home/mambauser`. Volume mounting should be done with caution here, so as not to overwrite hidden bash files which automatically set up conda.

A minimal example:

```bash
docker run --rm \
	-v "$(pwd):/mnt/host" \
	ashtonvcole/kalpana-tacc:latest \
		--storm test \
		--filename /mnt/host/maxele.63.nc \
		--filetype maxele.63.nc \
		--output /mnt/host/output/
```

## Known Issues

- **Palette specification for KMZ.** Although there are palette files available within the Kalpana repository, because the script references them using a path relative to the working directory, the `--palettename` flag must be used with an adjusted path.