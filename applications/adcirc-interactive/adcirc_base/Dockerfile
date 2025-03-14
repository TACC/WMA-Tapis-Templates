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


USER root

COPY --from=figuregen_build /usr/local/bin/figuregen /usr/local/bin/figuregen
COPY --from=figuregen_build /usr/local/bin/figuregen-serial /usr/local/bin/figuregen-serial
COPY --from=figuregen_data /gmt-4.5.18 /gmt-4.5.18

SHELL ["/bin/bash", "-c"]
