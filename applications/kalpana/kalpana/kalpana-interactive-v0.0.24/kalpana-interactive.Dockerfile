# Grass base

# Microconda base
FROM mambaorg/micromamba:2.3

# Metadata
LABEL maintainer="CHG-Ashton C. <ashtonc24@utexas.edu>"

# Automate versions
ARG DOCKER_BUILD_KALPANA_VERSION="0.0.24"
ARG DOCKER_BUILD_PYTHON_VERSION="3.11"

# Activate environment while building
ARG MAMBA_DOCKERFILE_ACTIVATE=1

# If someone wants to use --entrypoint=="python script.py"
ENV PATH="/opt/conda/bin:$PATH"

# Root privileges to install certain software
USER root
WORKDIR /

# Install Linux packages
# - build-essential for gcc, as a prerequisite for gdal, fiona, geopandas
# - grass as a dependency
# - wget to download Kalpana
RUN apt-get update \
	&& apt-get install -y \
		build-essential \
		grass=8.2.1-1 \
		wget \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download and unzip essentials from Kalpana release
# Properly rename Kalpana.py to kalpana.py
# Make /app readable but not editable to user
RUN mkdir /app \
	&& cd /app \
	&& wget "https://github.com/ccht-ncsu/Kalpana/archive/refs/tags/v${DOCKER_BUILD_KALPANA_VERSION}.tar.gz" \
	&& tar -zxf "v${DOCKER_BUILD_KALPANA_VERSION}.tar.gz" "Kalpana-${DOCKER_BUILD_KALPANA_VERSION}/kalpana" \
	&& tar -zxf "v${DOCKER_BUILD_KALPANA_VERSION}.tar.gz" "Kalpana-${DOCKER_BUILD_KALPANA_VERSION}/pyproject.toml" \
	&& tar -zxf "v${DOCKER_BUILD_KALPANA_VERSION}.tar.gz" "Kalpana-${DOCKER_BUILD_KALPANA_VERSION}/README.md" \
	&& mv "Kalpana-${DOCKER_BUILD_KALPANA_VERSION}/kalpana/Kalpana.py" "Kalpana-${DOCKER_BUILD_KALPANA_VERSION}/kalpana/kalpana.py" \
	&& touch "Kalpana-${DOCKER_BUILD_KALPANA_VERSION}/kalpana/__init__.py" \
	&& rm -rf "v${DOCKER_BUILD_KALPANA_VERSION}.tar.gz" \
	&& chmod -R 755 /app

# Back to ordinary user
# Not recommended to use conda/pip as root
USER $MAMBA_USER

# Using micromamba to install some libraries due to dependency problems
RUN micromamba install -c conda-forge -y \
		python==$DOCKER_BUILD_PYTHON_VERSION \
		pip \
		geopandas==0.12.2 \
		jupyterlab \
		psycopg==3.1.18 \
	&& micromamba clean --all -f -y

# Install dependencies from pyproject.toml
# Following official installation instructions
RUN cd "/app/Kalpana-${DOCKER_BUILD_KALPANA_VERSION}" \
	&& python -m pip install -e .
	
# Working directory is home directory
WORKDIR /home/mambauser

# Startup command: run Kalpana
# Prefix _entrypoint.sh to run with conda environment activated
# Note in release, file is capitalized
# ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "python" , "/app/kalpana/Kalpana.py"]
# Startup command: run Jupyter Lab
ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "jupyter", "lab"]

# Default argument: show help
# CMD ["--help"]
# Default arguments: setup containerized Jupyter
CMD ["--ip", "0.0.0.0", "--no-browser"]