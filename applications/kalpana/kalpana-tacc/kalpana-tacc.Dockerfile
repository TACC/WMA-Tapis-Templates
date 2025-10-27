# Microconda base
FROM mambaorg/micromamba:2.3

# Metadata
LABEL maintainer="CHG-Ashton C. <ashtonc24@utexas.edu>"
# Also credit to Carlos del Castillo Negrete

# Automate versions
ARG DOCKER_BUILD_KALPANA_VERSION="0.0.24"
ARG DOCKER_BUILD_PYTHON_VERSION="3.11"

# Activate environment while building
ARG MAMBA_DOCKERFILE_ACTIVATE=1

# Root privileges make changes
USER root
WORKDIR /

# Install packages
# - build-essential for gcc, as a prerequisite for gdal, fiona, geopandas
# - git to download Kalpana
RUN apt-get update \
	&& apt-get install -y \
		build-essential \
		git \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download TACC Kalpana fork
# Includes several ancillary scripts if needed
RUN mkdir /app \
	&& cd /app \
	&& git clone https://github.com/TACC/Kalpana

# Using micromamba to install libraries
RUN micromamba install -c conda-forge -y \
		python==$DOCKER_BUILD_PYTHON_VERSION \
		fiona \
		matplotlib==3.9.* \
		netCDF4 \
		numpy==2.2.* \
		simplekml \
	&& micromamba clean --all -f -y

# Back to ordinary user
USER $MAMBA_USER
WORKDIR /home/mambauser

# Startup command: run Kalpana
# Prefix _entrypoint.sh to run with conda environment activated
ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "python" , "/app/Kalpana/Kalpana_N.py"]

# Default argument: show help
CMD ["--help"]