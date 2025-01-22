### OpenSees Interactive

This app runs on a VM using apptainer. The image is built from 3 Dockerfiles to create the following 3 images:

1. [docker://taccaci/opensees](https://github.com/TACC/WMA-Tapis-Templates/blob/eb08b79f1dec77ba64e7274d2385e73ac32f9aa1/applications/opensees-express/opensees-interactive.Dockerfile)
    a. This image hosts the OpenSees binaries
2. [docker://taccaci/jupyterlab-matlab:R2022b-ubuntu-22.04](https://github.com/TACC/WMA-Tapis-Templates/blob/main/applications/opensees-interactive/matlab.Dockerfile)
    a. This image includes Matlab built into the jupyter lab image
3. [docker://taccaci/opensees-interactive:3.7.0-matlab-R2022b](https://github.com/TACC/WMA-Tapis-Templates/blob/9c17085234a6e65836a066cadedd4b8e8f3837b1/applications/opensees-interactive/Dockerfile)
    a. This image combines jupyter lab with the OpenSees binaries

## To build the final image (#3)
1. ssh to `wma-exec-01`
2. Copy or checkout `matlab.Dockerfile`
3. `docker build -t taccaci/jupyterlab-matlab:R2022b-ubuntu-22.04 -f matlab.Dockerfile .`
4. Copy or checkout `opensees-interactive.Dockerfile` and `run.sh`
5. `docker build -t taccaci/opensees-interactive:3.7.0-matlab-R2022b -f opensees-interactive.Dockerfile .`
6. `apptainer build /opt/apptainer-images/opensees-interactive-matlab.sif docker-daemon://taccaci/opensees-interactive:3.7.0-matlab-R2022b`
