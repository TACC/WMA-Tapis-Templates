######################################################
#
# OpenSeesMP image
# Tag: taccaci/opensees-mp:3.5.0
#
# Attribution: This Dockerfile and corressponding Makefile was modified from original version created by TAPIS-Project; 
# see the original repository here: 
# https://github.com/tapis-project/application-repository/tree/main/opensees-mp
#
# This is a vanilla installation of OpenSeesMP 3.5.0 on Ubuntu 20.04 compiled with Intel MPI. 
# To run your own input, mount your data to the /data volume and
# specify the traditional invocation command
#
# ibrun singularity run -it --rm -v `pwd`:/data taccaci/opensees-mp:3.5.0 /bin/sh -c 'OpenSeesMP < /data/myinput.tcl'
#
# The data will appear in your current directory at the end of the run.
# 
######################################################

# From TACC containers: https://github.com/TACC/tacc-containers
FROM tacc/tacc-ubuntu18-impi19.0.7-common:latest
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
# Get external packages including Intel MKL
RUN echo deb https://apt.repos.intel.com/mkl all main > /etc/apt/sources.list.d/intel-mkl.list && \
    apt-get -y update && \
    apt-get -y install intel-mkl-64bit-2020.1-102 && \
    apt-get -y install git vim-tiny make cmake tcl8.6 tcl8.6-dev gcc g++ gfortran python3-dev wget && \
    docker-clean && \
    sed -i '3 i . /opt/intel/compilers_and_libraries/linux/mkl/bin/mklvars.sh intel64 mod' /entry.sh && \
    useradd --create-home ubuntu
# Build MUMPS
RUN cd /home/ubuntu && \
    mkdir bin lib && \
    wget http://graal.ens-lyon.fr/MUMPS/MUMPS_5.2.1.tar.gz && \
    tar -xf MUMPS_5.2.1.tar.gz && rm MUMPS_5.2.1.tar.gz && \
    cd MUMPS_5.2.1 && \
    cp Make.inc/Makefile.INTEL.PAR Makefile.inc && \
    sed -i 's/mpiicc/mpicc/g' Makefile.inc && \
    sed -i 's/mpiifort/mpif90/g' Makefile.inc && \
    sed -i 's/OPTF    =.*/OPTF    = -O3 -fopenmp/g' Makefile.inc && \
    sed -i 's/OPTL    =.*/OPTL    = -O3 -fopenmp/g' Makefile.inc && \
    sed -i 's/OPTC    =.*/OPTC    = -O3 -fopenmp/g' Makefile.inc && \
    make -j mumps_lib && mkdir ../mumps && mv lib ../mumps/lib && mv include ../mumps/include && \
    cd .. && rm -rf MUMPS_5.2.1
# Build OpenSeesMP. Note PARALLEL_INTERPRETERS configures Makefile to build MP.
ADD makes/Makefile.def /home/ubuntu/Makefile.def
RUN cd /home/ubuntu && source /entry.sh && git clone https://github.com/OpenSees/OpenSees.git && \
    cd OpenSees && \
    git checkout v3.5.0 && cp ../Makefile.def ./ && \
    PROGRAMMING_MODE=PARALLEL_INTERPRETERS make -j 28 && \
    mv EXAMPLES/SmallMP ../SmallMP && cd .. && rm -rf OpenSees Makefile.def
RUN mv /home/ubuntu/SmallMP /data/SmallMP
RUN chown -R ubuntu:ubuntu /home/ubuntu /data
ENV HOME=/home/ubuntu \
    NB_USER=
USER ubuntu
WORKDIR /data
ENV PATH $PATH:/home/ubuntu/bin
VOLUME ["/data"]
CMD [ "/bin/sh", "-c", "OpenSeesMP" ]