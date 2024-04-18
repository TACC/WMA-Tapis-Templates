FROM ubuntu:20.04

LABEL maintainer="TACC-ACI-WMA <wma_prtl@tacc.utexas.edu>"

ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=Etc/UTC

RUN apt-get update && apt-get install -y \
    tzdata \
    git \
    cmake \
    gcc \
    g++ \
    gfortran \
    liblapack-dev \
    git \
    python3-pip \
    openmpi-bin \
    openmpi-common \
    libopenmpi-dev \
    libscalapack-openmpi-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opensees

RUN pip install --upgrade \
    pip \
    setuptools \
    wheel

RUN pip install conan==1.60.1

RUN git clone --depth 1 --branch hdf5-1_12_2 https://github.com/HDFGroup/hdf5.git \
    && cd hdf5 \
    && ./configure --prefix=/usr/local/hdf5 \
    && make \
    && make check \
    && make install \
    && make check-install

RUN git clone https://github.com/OpenSees/mumps.git \
    && cd mumps \
    && mkdir build \
    && cd build \
    && cmake .. -Darith=d \
    && cmake --build .

RUN git clone https://github.com/OpenSees/OpenSees.git \
    && cd OpenSees \
    && mkdir build \
    && cd build \
    && conan install .. --build missing \
    && cmake .. -DMUMPS_DIR=$PWD/../../mumps/build -DOPENMPI=TRUE -DSCALAPACK_LIBRARIES="/usr/lib/x86_64-linux-gnu/libscalapack-openmpi.so.2.1" \
    && cmake --build . --config Release --target OpenSees \
    && cmake --build . --config Release --target OpenSeesPy \
    && cmake --build . --config Release --target OpenSeesSP \
    && cmake --build . --config Release --target OpenSeesMP \
    && cp ./bin/* /usr/local/bin \
    && cp -r ./lib/tcl8.6 /usr/local/lib \
    && cd ../.. \
    && rm -rf OpenSees \
    && rm -rf hdf5 \
    && rm -rf hdf5 mumps

RUN pip install \
    h5py

RUN useradd --create-home ubuntu

USER ubuntu

SHELL ["/bin/bash", "-c"]

WORKDIR /data
