FROM jupyter/minimal-notebook:latest AS base

USER root
WORKDIR /
LABEL maintainer="TACC-Carlos D. <carlosd@tacc.utexas.edu>"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        git \
        wget \
        mpich \
        ghostscript \
        graphicsmagick \
        gdal-bin \
        ffmpeg \
        libxt-dev \
        libxaw7-dev \
        libhdf5-dev \
        libnetcdff-dev \
        cmake \
        ca-certificates \
        gpg \
        git-lfs \
        ssh \
        libboost-dev \
        libxml2-dev \
        libjpeg-dev \
        python3 \
        sshfs \
        netcdf-bin \
        libopenmpi-dev \
        bc \
        gfortran \
        perl \
        gcc \
        g++ \
        tar \
        gzip \
        zlib1g-dev \
        libcurl4-openssl-dev \
        software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM base AS figuregen_data

WORKDIR /
LABEL maintainer="TACC-Carlos D. <carlosd@tacc.utexas.edu>"
ARG DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /data
RUN wget https://fossies.org/linux/misc/GMT/gmt-4.5.18-src.tar.bz2 \
    && tar -xf gmt-4.5.18-src.tar.bz2 \
    && cd gmt-4.5.18/ \
    && ./configure --enable-netcdf \
    && make \
    && make install-gmt \
    && make install-data \
    && make clean \
    && wget https://fossies.org/linux/misc/GMT/gshhg-gmt-2.3.7.tar.gz \
    && tar -zxvf gshhg-gmt-2.3.7.tar.gz \
    && cd share \
    && mkdir coast \
    && cd coast \
    && mv /gmt-4.5.18/gshhg-gmt-2.3.7/* .

FROM figuregen_data AS figuregen_build

COPY --from=figuregen_data /gmt-4.5.18 /usr/local/gmt-4.5.18
RUN git clone https://github.com/cdelcastillo21/FigureGen.git /figuregen 

RUN cd figuregen \
    && ls \
    && mkdir build \
    && cd build \
    && cmake .. -DCMAKE_Fortran_COMPILER=gfortran -DUSE_MPI=OFF -DUSE_NETCDF=ON -DCMAKE_Fortran_FLAGS="-fallow-argument-mismatch" \
    && make \
    && cp figuregen /usr/local/bin/figuregen-serial \
    && cd .. && rm -rf build \
    && mkdir build \
    && cd build \
    && cmake .. -DCMAKE_Fortran_COMPILER=mpif90 -DUSE_MPI=ON -DUSE_NETCDF=ON -DCMAKE_Fortran_FLAGS="-fallow-argument-mismatch" \
    && make \
    && cp figuregen /usr/local/bin/figuregen \
    && cp -r /figuregen/autotest /usr/local/share/figuregen-tests

ENV PATH="/figuregen/build:/gmt-4.5.18/bin:${PATH}"

FROM base AS adcirc_build

COPY adcirc_compile.sh /usr/local/bin/adcirc_compile
RUN chmod +x /usr/local/bin/adcirc_compile && \
    adcirc_compile v56.0.2 https://github.com/adcirc/adcirc 1 /usr/local/src/adcirc-v56.0.2

FROM base AS jupyter_lab_base

RUN mamba install -c conda-forge -y \
        jupyterlab=4.1.8 \
		ipykernel \
		nodejs \
		flake8 \
		black \
		isort \
		autopep8 \
		ipympl \
		yapf \
		jupyter_bokeh \
		jupyterlab-lsp \
		python-lsp-server  \
		jupyterlab-git \
		jupyterlab-spellchecker \
		jlab-enhanced-cell-toolbar \
		curl && \
	mamba clean --all -f -y && \
    pip install \
		ipympl \
		jupyterlab_code_formatter \
        jupyterlab_favorites \
		jupyterlab-link-share  \
		jupyterlab_recents \
        jupyter-collaboration \
		jupyterlab_theme_solarized_dark 
		# jupyterlab-vim \
		# jupyterlab-topbar  \
		# jupyterlab-topbar-text \

RUN jupyter lab build


FROM jupyter_lab_base AS python_kernels

RUN rm -rf /home/jovyan/.cache 
USER jovyan
WORKDIR /home/jovyan

# Python wants to build from 
SHELL ["/bin/bash", "-o", "pipefail", "-c", "-i"]
RUN mamba create --name kalpana -y -c conda-forge \
        python=3.11 \
        ipykernel \
        fiona \
        cmocean \
        matplotlib \
        numpy \
        geopandas \
        pandas \
        shapely \
        tqdm \
        netCDF4 \
        simplekml \
        scipy \
        pathlib \
        rioxarray \
        loguru \
        pyproj \
        cartopy && \
	mamba clean --all -f -y && \
    conda activate kalpana && \
    ipython kernel install --user --name=kalpana && \
    git clone https://github.com/cdelcastillo21/TACC-Kalpana Kalpana && \
    cd Kalpana && \
    pip install -e .

# ML Kernel - Useful? 
# RUN mamba create --name ml -y -c conda-forge \
#         python=3.11 \
#         jax \
#         jaxlib \
#         pytorch \
#         torchvision \
#         tensorflow \
#         tensorflow-probability \
#         scikit-learn \
#         scikit-image \
#         pandas \
#         numpy \
#         matplotlib \
#         seaborn \
#         xarray \
#         dask \
#         mlflow && \
# 	mamba clean --all -f -y && \
#     conda activate ml && \
#     ipython kernel install --user --name=ml

FROM python_kernels AS final

USER root

COPY --from=figuregen_build /usr/local/bin/figuregen /usr/local/bin/figuregen
COPY --from=figuregen_build /usr/local/bin/figuregen-serial /usr/local/bin/figuregen-serial
COPY --from=figuregen_data /gmt-4.5.18 /gmt-4.5.18
COPY --from=adcirc_build /usr/local/bin/adcprep /usr/local/bin/adcprep
COPY --from=adcirc_build /usr/local/bin/adcirc /usr/local/bin/adcirc
COPY --from=adcirc_build /usr/local/bin/padcirc /usr/local/bin/padcirc
COPY --from=adcirc_build /usr/local/bin/adcswan /usr/local/bin/adcswan
COPY --from=adcirc_build /usr/local/bin/padcswan /usr/local/bin/padcswan
COPY --from=adcirc_build /usr/local/bin/adcirc_compile /usr/local/bin/adcirc_compile

COPY run.sh /tapis/run.sh
RUN chmod +x /tapis/run.sh

RUN groupadd --gid 816877 G-816877
RUN usermod -u 458981 -G G-816877 jovyan
USER 458981

WORKDIR /home/jovyan
ENTRYPOINT [ "/tapis/run.sh" ]
SHELL ["/bin/bash", "-c"]
