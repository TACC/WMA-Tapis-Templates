# ADCIRC Interactive App

JupyterLab Instance with ADCIRC and supporting applications (FigureGen and Kalpana) installed natively.

## Building Docker Image

The Dockerfile to build the ADCIRC Interactive App Image uses a multi-stage build. You must use [docker buildx](https://docs.docker.com/reference/cli/docker/buildx/) to build the container. You can build it in stages, such as:

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t clos21/ds-adcirc-interactive:latest --target final --load --push .
```

This command:
- Builds for both AMD64 and ARM64 architectures. Note the current vm where the adcirc interactive app is deployed requires linux/amd64
- Tags the image as `clos21/ds-adcirc-interactive:base`
- Uses the `base` stage in a multi-stage Dockerfile. Will build only up to this stage, and give it the above tag name
- Loads the image into Docker's local image store
- Pushes the image to the configured registry (only do this when ready to push the image out)

Ensure you're in the directory containing your Dockerfile when running this command.

## Multi-stage Build Structure

This Dockerfile uses a multi-stage build to create an interactive ADCIRC environment. Here's an overview of the different stages and what each adds:

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

5. **jupyter_lab_base**: 
   - Builds on `base`
   - Installs JupyterLab and related extensions

6. **python_kernels**: 
   - Builds on `jupyter_lab_base`
   - Sets up Python environments and installs scientific packages

7. **final**: 
   - Builds on `python_kernels`
   - Copies built artifacts from previous stages
   - Sets up final environment configurations


The container build tree can thus be visualized as:

```
base
├── figuregen_data
│   └── figuregen_build
├── adcirc_build
└── jupyter_lab_base
    └── python_kernels
        └── final
```

**Warning**: Sometimes the python kernel build fails (specifically mamba) due to weird bugs with parallelization issues. Try building the images in stages if this happpens.