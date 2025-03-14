# ADCIRC Interactive App

JupyterLab Instance with ADCIRC and supporting applications (FigureGen and Kalpana) installed natively.

## Building Docker Images

There are two Docker images to build for the ADCIRC Interactive App:

1. `adcirc_base` image - Dockerfile in the `adcirc_base` folder, builds FigureGen and ADCIRC compiled Fortran codes.
2. `adcirc_interactive` image - Sets up JupyterLab and Python kernels.

The multi-stage build structure still exists, but both images have the same base. The `figuregen_data` and `adcirc_build` stages are in the `adcirc_base` image, and the rest are in the `adcirc_interactive` image.

### Building `adcirc_base` Image

The Dockerfile to build the `adcirc_base` image uses a multi-stage build. You must use [docker buildx](https://docs.docker.com/reference/cli/docker/buildx/) to build the container. You can build it in stages, such as:

```bash
docker buildx build --platform linux/amd64,linux/arm64 --target base --load -f adcirc_base/Dockerfile .
```

to build the base image.

### Building `adcirc_interactive` Image

To build the `adcirc_interactive` image, use the following command:

```bash
docker buildx build --platform linux/amd64,linux/arm64 --target final --load -f adcirc_interactive/Dockerfile .
```

## Building Container with Docker Buildx

This README explains how to build multi-architecture container images using Docker Buildx for an interactive ADCIRC environment.

## Prerequisites

- Docker installed on your system
- Docker Buildx plugin (included with Docker Desktop and recent Docker Engine versions)

## What is Docker Buildx?

Docker Buildx is a CLI plugin that extends Docker's build capabilities. It allows you to build images for multiple platforms simultaneously and provides enhanced build features.

## Activating Docker Buildx

1. Check if Buildx is installed:
   ```
   docker buildx version
   ```

2. If not installed, you may need to enable experimental features in Docker.

3. Create a new Buildx builder instance:
   ```
   docker buildx create --name mybuilder --use
   ```

## Building the Containers

To build and push the container images for multiple architectures, use the following commands:

### Building `adcirc_base` Image

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t clos21/ds-adcirc-base:latest --target final --load --push -f adcirc_base/Dockerfile .
```

### Building `adcirc_interactive` Image

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t clos21/ds-adcirc-interactive:latest --target final --load --push -f adcirc_interactive/Dockerfile .
```

Ensure you're in the directory containing your Dockerfiles when running these commands.

## Multi-stage Build Structure

The Dockerfiles use a multi-stage build to create an interactive ADCIRC environment. Here's an overview of the different stages and what each adds:

### `adcirc_base` Dockerfile

1. **base**: 
   - Starting point based on jupyter/minimal-notebook
   - Installs system dependencies and tools

2. **figuregen_data**: 
   - Builds on `base`
   - Downloads and installs GMT (Generic Mapping Tools)

3. **figuregen_build**: 
   - Builds on `figuregen_data`
   - Clones and compiles FigureGen

4. **adcirc_build**: 
   - Builds on `base`
   - Compiles ADCIRC

### `adcirc_interactive` Dockerfile

1. **jupyter_lab_base**: 
   - Builds on `base`
   - Installs JupyterLab and related extensions

2. **python_kernels**: 
   - Builds on `jupyter_lab_base`
   - Sets up Python environments and installs scientific packages

3. **final**: 
   - Builds on `python_kernels`
   - Copies built artifacts from previous stages
   - Sets up final environment configurations

The container build tree can thus be visualized as:

```
adcirc_base
├── figuregen_data
│   └── figuregen_build
└── adcirc_build

adcirc_interactive
└── jupyter_lab_base
    └── python_kernels
        └── final
```

**Warning**: Sometimes the Python kernel build fails (specifically mamba) due to weird bugs with parallelization issues. Try building the images in stages if this happens.

## Testing the Container Locally

To test the ADCIRC Interactive container locally, you can use the provided `test_local_run.sh` script. This script will launch the container and start a JupyterLab instance.

### Prerequisites

- Docker installed on your system

### Steps

1. Ensure you are in the directory containing the `test_local_run.sh` and `test_app.sh` scripts.
2. Make the `test_local_run.sh` script executable:
   ```bash
   chmod +x test_local_run.sh
   ```
3. Run the `test_local_run.sh` script:
   ```bash
   ./test_local_run.sh
   ```

This will start the Docker container and launch JupyterLab. You can access JupyterLab by opening your web browser and navigating to `http://localhost:8888`.

Note: The `test_local_run.sh` script mounts the current working directory into the container and uses `test_app.sh` as the entrypoint.

## Deploying Tapis Application

The Jupyter notebook `deploy.ipynb` contains the necessary pyhton code to deploy the Tapis application for the interactive ADCIRC VM. 
Note that the only application code needed by this VM is the tapisjob_app.sh script that launches the Jupyter Lab image created by the Dockerfile.