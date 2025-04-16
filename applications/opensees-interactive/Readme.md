### OpenSees Interactive

This app runs on a VM using apptainer. The image is built from 3 Dockerfiles to create the following 3 images:

1. [docker://taccaci/opensees](https://github.com/TACC/WMA-Tapis-Templates/blob/main/applications/opensees-express/opensees-interactive.Dockerfile)
    a. This image hosts the OpenSees binaries
2. [docker://taccaci/jupyterlab-matlab:R2022b-ubuntu-22.04](https://github.com/TACC/WMA-Tapis-Templates/blob/main/applications/opensees-interactive/matlab.Dockerfile)
    a. This image includes Matlab built into the jupyter lab image
3. [docker://taccaci/opensees-interactive:matlab-R2022b](https://github.com/TACC/WMA-Tapis-Templates/blob/main/applications/opensees-interactive/Dockerfile)
    a. This image combines jupyter lab with the OpenSees binaries

## To build the final image (#3)
1. ssh to `wma-exec-01`
2. Copy or checkout `matlab.Dockerfile`
3. `docker build -t taccaci/jupyterlab-matlab:R2024b-ubuntu-24.04 -f matlab.Dockerfile .`
4. Copy or checkout `opensees-interactive.Dockerfile` and `run.sh`
5. `docker build -t taccaci/opensees-interactive:matlab-R2022b -f opensees-interactive.Dockerfile .`
6. `apptainer build /opt/apptainer-images/opensees-interactive-latest-matlab.sif docker-daemon://taccaci/opensees-interactive:matlab-R2022b`
