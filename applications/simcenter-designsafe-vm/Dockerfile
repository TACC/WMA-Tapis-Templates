## taccaci/designsafe-simcenter-vm:0.0.1 ##

FROM ubuntu:20.04

LABEL maintainer="TACC-ACI-WMA <wma_prtl@tacc.utexas.edu>"

ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=Etc/UTC

RUN apt-get update && apt-get install -y \
    python3-pip 

RUN pip install --upgrade \
    pip \
    setuptools \
    wheel

RUN pip install \
    h5py \
    numpy \
    pandas \
    xarray \
    tables \
    netcdf4 \
    h5netcdf \
    scipy

RUN useradd --create-home ubuntu

USER ubuntu

SHELL ["/bin/bash", "-c"]