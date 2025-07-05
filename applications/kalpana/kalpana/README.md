# Kalpana Image

## What is Kalpana?

Kalpana is a Python script for post-processing of ADCIRC output files into GIS vector formats. The program was developed by the Coastal and Computational Hydraulics Team and North Carolina State University. For more details, check the [Kalpana repository](https://github.com/ccht-ncsu/Kalpana).

See Docker Hub page: [ashtonvcole/kalpana](https://hub.docker.com/r/ashtonvcole/kalpana)

## Image Description

This image is built on top of [mambaorg/micromamba](https://hub.docker.com/r/mambaorg/micromamba):2.3. It sets up all necessary dependencies in the base environment and imports its code from [official releases of Kalpana](https://github.com/ccht-ncsu/Kalpana/releases) into `/app`. To permit interactive use, Jupyter Lab is also included.

## Tags

- `latest`, `v0.0.24`: Intended for Python scripts. The entrypoint of the image runs the script, `ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "python"]`. The default working directory is `/home/mambauser`.
- `latest-jupyter-lab`, `v0.0.24-jupyter-lab`: Intended for interactive use with Jupyter Lab. The entrypoint of the image runs the script, `ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "jupyter" , "lab"]`. The default arguments are `CMD ["--ip", "0.0.0.0", "--no-browser"]`. The default working directory is `/home/mambauser`.

## Usage

Because the main run script of Kalpana is limited and broken, one should instead use Kalpana indirectly by importing necessary modules into a Jupyter Notebook or Python script. The user should make ADCIRC files accessible to the container via a volume mount, and then direct the Kalpana outputs to the same or another mount.

By default, the container runs from the working directory `/home/mambauser`. Volume mounting should be done with caution here, so as not to overwrite hidden bash files which automatically set up conda.

For more specific help using Kalpana, check out [examples](https://github.com/ccht-ncsu/Kalpana/tree/master/examples) of its functionality written in Jupyter notebooks.

### In Batch with a Python Script

For example, to convert an ADCIRC output to shapefile contours, one might write a minimal script like the following, with variables substituted approriately. One should be wary that the file paths are relative to the default working directory `/home/mambauser` within the container.

```python
from kalpana.export import nc2shp

gdf = nc2shp(
    ncFile,
    var,
    levels,
    conType,
    pathOut,
    epsgOut,
    vUnitOut=vUnitOut,
    vUnitIn=vUnitIn,
    epsgIn=epsgIn,
    subDomain=subDomain,
    exportMesh=exportMesh,
    meshName=meshName,
    dzFile=dzFile,
    zeroDif=zeroDif,
    maxDif=maxDif,
    distThreshold=distThreshold,
    k=k,
    timesteps=timesteps
)
```

Assuming that the script is in the working directory, it could then be mounted and executed in the container with an adjusted entrypoint.

```bash
docker run --rm -it \
	-p 8888:8888 \
	-v "$(pwd):/mnt/host" \
	--entrypoint="python" \
	ashtonvcole/kalpana:v0.0.24 \
		script.py
```

### Interactively with Jupyter Lab

The container is set to run interactively by default. To do so, one just needs to specify a port bind and volume mount to the host.

```bash
docker run --rm -it \
	-p 8888:8888 \
	-v "$(pwd):/mnt/host" \
	ashtonvcole/kalpana:v0.0.24-jupyter-lab
```

## Known Issues

- **Run script is broken.** Function `main()` in `kalpana.py` is written with Catch-22's related to required flags which make the script unusable. It only offers restricted functionality, anyways.
- **Importing `kalpana.kalpana` is broken.** Attempting to import `kalpana.py` will result in an error. It is not necessary for leveraging Kalpana export and downscaling functions, which are defined in other modules.