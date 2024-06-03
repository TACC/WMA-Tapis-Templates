FROM jupyter/base-notebook:ubuntu-20.04

# The user must be swtiched to root in order to install and update packages with apt-get.
# See https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile for info.
USER root

LABEL maintainer="TACC-ACI-WMA <wma_prtl@tacc.utexas.edu>"

ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=Etc/UTC

RUN apt-get update && apt-get install -y \
    tzdata \
    curl \
    git \
    cmake \
    gcc \
    g++ \
    gfortran \
    liblapack-dev \
    git \
    tcl8.6 \
    tcl8.6-dev \
    zip \
    unzip \
    openmpi-bin \
    openmpi-common \
    libopenmpi-dev \
    libscalapack-openmpi-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade \
    pip \
    setuptools \
    wheel

RUN pip install \
    h5py \
    openseespy \
    numpy \
    pandas \
    matplotlib \
    mpi4py \
    ipywidgets

COPY --from=taccaci/opensees:3.6.0 /usr/local/bin/OpenSees /usr/local/bin/OpenSees
COPY --from=taccaci/opensees:3.6.0 /usr/local/bin/OpenSeesSP /usr/local/bin/OpenSeesSP
COPY --from=taccaci/opensees:3.6.0 /usr/local/bin/OpenSeesMP /usr/local/bin/OpenSeesMP

COPY --from=taccaci/opensees:3.6.0 /usr/local/lib/tcl8.6 /usr/local/lib/tcl8.6

COPY run.sh /tapis/run.sh

RUN chmod +x /tapis/run.sh

ENTRYPOINT [ "/tapis/run.sh" ]

SHELL ["/bin/bash", "-c"]
